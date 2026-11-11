# Shared helpers sourced by macstrap scripts. Compatible with macOS /bin/bash 3.2.

set -euo pipefail

YELLOW=$'\033[33m'
RED=$'\033[31m'
RESET=$'\033[0m'

header() { printf '\n━━━ %s\n' "$*"; }
info() { printf '%s\n' "$*"; }
warn() { printf '%s%s%s\n' "$YELLOW" "$*" "$RESET" >&2; }
fail() {
  printf '%s%s%s\n' "$RED" "$*" "$RESET" >&2
  exit 1
}

confirm() {
  local reply
  read -r -p "$1 [y/N]: " reply || true
  [[ "$reply" == [yY] ]]
}

pause() {
  read -r -p "$1" _ || true
}

# Returns 0 (skip) when a key is pressed within the timeout; never skips without a terminal.
skip_step() {
  local step="$1" timeout="${2:-5}"
  [[ -t 0 ]] || return 1
  warn "Press any key within ${timeout} seconds to skip: ${step}"
  if read -r -s -n 1 -t "$timeout"; then
    warn "Skipping: ${step}"
    return 0
  fi
  return 1
}

# Offers the skip prompt only when the step runs as part of the full setup workflow.
workflow_skip_step() {
  [[ "${MACSTRAP_WORKFLOW:-false}" == "true" ]] && skip_step "$1"
}

has_command() { command -v "$1" >/dev/null 2>&1; }

usage() {
  fail "Usage: $(basename "$0") <$1>"
}
