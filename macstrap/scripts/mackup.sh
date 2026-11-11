#!/usr/bin/env bash
# Restores or backs up application preferences with Mackup.
source "$(dirname "$0")/../lib/common.sh"

: "${MACKUP_DIR:?}"

mackup_ready() {
  has_command mackup && [[ -f "$HOME/.mackup.cfg" ]]
}

setup() {
  workflow_skip_step "Restore Mackup Backups" && return 0
  header "🗂️ Restore Mackup Backups"
  if [[ ! -d "$MACKUP_DIR" ]] || ! mackup_ready; then
    warn "⚠️ Skipping Mackup restore - prerequisites not met"
    return 0
  fi

  mackup restore
  info "✅ Mackup restored"
}

backup() {
  header "🗃️ Backup Mackup"
  mackup_ready || fail "⚠️ Mackup is not installed or config not found at ~/.mackup.cfg"

  mackup backup --force
  info "✅ Mackup backup complete"
  info "📁 Mackup files were backed up to the location configured in ~/.mackup.cfg"
  warn "📌 Remember to store the mackup folder somewhere safe"
}

case "${1:-}" in
  setup) setup ;;
  backup) backup ;;
  *) usage "setup|backup" ;;
esac
