#!/usr/bin/env bash
# Enables Touch ID for sudo through /etc/pam.d/sudo_local.
source "$(dirname "$0")/../lib/common.sh"

: "${SUDO_LOCAL_FILE:?}" "${SUDO_LOCAL_RULE:?}" "${SUDO_LOCAL_MODE:?}"

setup() {
  workflow_skip_step "Configure Touch ID for sudo" && return 0
  header "🔧 Configure Touch ID for sudo"

  if [[ -f "$SUDO_LOCAL_FILE" ]] && grep -qxF "$SUDO_LOCAL_RULE" "$SUDO_LOCAL_FILE"; then
    info "✅ Touch ID for sudo is already configured"
    return 0
  fi

  printf '%s\n' "$SUDO_LOCAL_RULE" | sudo tee "$SUDO_LOCAL_FILE" >/dev/null
  sudo chown root:wheel "$SUDO_LOCAL_FILE"
  sudo chmod "$SUDO_LOCAL_MODE" "$SUDO_LOCAL_FILE"
  info "✅ Touch ID for sudo configured successfully"
}

case "${1:-}" in
  setup) setup ;;
  *) usage setup ;;
esac
