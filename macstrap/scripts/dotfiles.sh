#!/usr/bin/env bash
# Symlinks dotfiles from the dotfiles directory into the home folder.
source "$(dirname "$0")/../lib/common.sh"

: "${DOTFILES_DIR:?}"

setup() {
  workflow_skip_step "Install Dotfiles" && return 0
  header "🔗 Install Dotfiles"

  if [[ ! -d "$DOTFILES_DIR" ]]; then
    warn "⚠️ Dotfiles directory not found at: $DOTFILES_DIR"
    return 0
  fi

  local entry name target
  for entry in "$DOTFILES_DIR"/.*; do
    name="$(basename "$entry")"
    case "$name" in
      . | .. | .DS_Store) continue ;;
    esac
    [[ -e "$entry" ]] || continue

    target="$HOME/$name"
    if [[ -e "$target" || -L "$target" ]]; then
      if ! confirm "$target already exists. Remove it?"; then
        info "Skipping $name"
        continue
      fi
      if [[ -d "$target" && ! -L "$target" ]]; then
        fail "Refusing to remove directory: $target"
      fi
      rm -f "$target"
    fi

    ln -s "$entry" "$target"
    info "Linked $name"
  done

  info "✅ Dotfiles complete"
}

case "${1:-}" in
  setup) setup ;;
  *) usage setup ;;
esac
