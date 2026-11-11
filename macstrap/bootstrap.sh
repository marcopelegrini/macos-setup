#!/bin/bash
# Prepares a fresh Mac for macstrap: installs Homebrew and Task, then runs the setup workflow.
# Usage: ./bootstrap.sh [task arguments], for example `./bootstrap.sh dotfiles:setup`.
set -euo pipefail

MACSTRAP_DIR="$(cd "$(dirname "$0")" && pwd)"

find_brew() {
  command -v brew 2>/dev/null && return 0
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    [[ -x "$candidate" ]] && printf '%s\n' "$candidate" && return 0
  done
  return 1
}

if ! brew="$(find_brew)"; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  brew="$(find_brew)" || { echo "Homebrew installation failed." >&2; exit 1; }
fi
eval "$("$brew" shellenv)"

if ! command -v task >/dev/null 2>&1; then
  echo "Installing Task..."
  brew install go-task
fi

if [[ $# -eq 0 ]]; then
  set -- setup
fi
exec task --taskfile "$MACSTRAP_DIR/Taskfile.yml" "$@"
