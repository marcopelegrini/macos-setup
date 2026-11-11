#!/usr/bin/env bash
# Installs the configured Mac App Store apps.
source "$(dirname "$0")/../lib/common.sh"

: "${MAS_CONFIG:?}"

setup() {
  workflow_skip_step "Install App Store Apps" && return 0
  header "🛍️ App Store Apps"
  if ! has_command mas; then
    warn "⚠️ mas-cli is not installed. Skipping App Store apps"
    return 0
  fi

  info "📲 Open the App Store and sign in with your Apple ID"
  pause "Press Enter when signed in..."

  local app_id
  for app_id in $(sed -e 's/#.*//' "$MAS_CONFIG"); do
    mas install "$app_id"
  done

  info "✅ Mac App Store apps installed"
}

case "${1:-}" in
  setup) setup ;;
  *) usage setup ;;
esac
