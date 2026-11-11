#!/usr/bin/env bash
# Applies the configured macOS settings.
source "$(dirname "$0")/../lib/common.sh"

: "${OSX_CONFIG:?}"

setup() {
  workflow_skip_step "Apply macOS Settings" && return 0
  header "⚙️ Apply macOS Settings"
  [[ -f "$OSX_CONFIG" ]] || fail "macOS settings not found at: $OSX_CONFIG"

  # Defines apply_settings and RESTART_APPLICATIONS.
  source "$OSX_CONFIG"
  apply_settings

  if confirm "Restart affected applications now?"; then
    local app
    for app in "${RESTART_APPLICATIONS[@]}"; do
      killall "$app" 2>/dev/null || true
    done
  fi

  info "Please log out and log back in to make all settings take effect."
}

case "${1:-}" in
  setup) setup ;;
  *) usage setup ;;
esac
