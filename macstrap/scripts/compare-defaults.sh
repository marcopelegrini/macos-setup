#!/usr/bin/env bash
# Prints the macOS defaults that change while you adjust a setting manually.
source "$(dirname "$0")/../lib/common.sh"

before="$(mktemp)"
after="$(mktemp)"
trap 'rm -f "$before" "$after"' EXIT

info "Capturing initial defaults..."
defaults read >"$before"
pause "Initial capture complete. Make your changes, then press Enter to continue..."
info "Capturing current defaults..."
defaults read >"$after"

printf '\n=== DIFFERENCES ===\n'
diff --unified=0 "$before" "$after" | grep -v '^@\|^---\|^+++' || true
