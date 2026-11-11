#!/usr/bin/env bash
# Replaces Dock items with the configured list.
source "$(dirname "$0")/../lib/common.sh"

: "${DOCK_CONFIG:?}"

resolve_item() {
  local item="$1" directory
  if [[ "$item" == /* ]]; then
    if [[ -e "$item" ]]; then
      printf '%s\n' "$item"
    fi
    return 0
  fi
  for directory in /Applications /System/Applications; do
    if [[ -e "$directory/$item.app" ]]; then
      printf '%s\n' "$directory/$item.app"
      return
    fi
  done
}

add_spacer() {
  dockutil --add '' --type spacer --section apps --no-restart
}

setup() {
  workflow_skip_step "Configure Dock" && return 0
  header "🧭 Configure Dock"
  has_command dockutil || fail "dockutil is not installed; run 'task homebrew:setup' first."
  [[ -f "$DOCK_CONFIG" ]] || fail "Dock configuration not found at: $DOCK_CONFIG"

  info "Removing all dock items..."
  dockutil --remove all --no-restart
  add_spacer

  local line item path previous_added=false
  while IFS= read -r line || [[ -n "$line" ]]; do
    item="${line%%#*}"
    item="$(printf '%s' "$item" | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')"
    [[ -n "$item" ]] || continue

    if [[ "$item" == "---" ]]; then
      if [[ "$previous_added" == true ]]; then
        add_spacer
      else
        info "Skipping spacer because the previous Dock item was not added."
      fi
      continue
    fi

    item="${item/#\~/$HOME}"
    path="$(resolve_item "$item")"
    if [[ -z "$path" ]]; then
      info "Skipping missing Dock item: $item"
      previous_added=false
      continue
    fi

    dockutil --add "$path" --no-restart
    previous_added=true
  done <"$DOCK_CONFIG"

  killall Dock 2>/dev/null || true
  info "✅ Dock configured"
}

case "${1:-}" in
  setup) setup ;;
  *) usage setup ;;
esac
