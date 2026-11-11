#!/usr/bin/env bash
# Guides the manual Raycast settings import and export.
source "$(dirname "$0")/../lib/common.sh"

setup() {
  workflow_skip_step "Restore Raycast Backup" && return 0
  header "🔦 Restore Raycast Backup"
  info "📍 Raycast > Preferences > Advanced > Import Settings"
  pause "Press Enter when done..."
  info "✅ Raycast restored"
}

backup() {
  header "🔦 Backup Raycast"
  info "Open Raycast"
  info "Go to Preferences > Advanced"
  info "Click 'Export Settings'"
  info "Save the backup file"
  pause "Press Enter when done..."
  info "✅ Raycast backup confirmed"
}

case "${1:-}" in
  setup) setup ;;
  backup) backup ;;
  *) usage "setup|backup" ;;
esac
