#!/usr/bin/env bash
# Installs Homebrew and the Brewfile bundle, or dumps and reviews the installed bundle.
source "$(dirname "$0")/../lib/common.sh"

: "${BREWFILE:?}"

find_brew() {
  local candidate
  if has_command brew; then
    command -v brew
    return 0
  fi
  for candidate in /opt/homebrew/bin/brew /usr/local/bin/brew; do
    if [[ -x "$candidate" ]]; then
      printf '%s\n' "$candidate"
      return 0
    fi
  done
  return 1
}

setup() {
  workflow_skip_step "Install Homebrew, Apps and CLIs" && return 0
  header "🍺 Install Homebrew, Apps and CLIs"

  local brew
  if brew="$(find_brew)"; then
    info "Homebrew already installed"
  else
    skip_step "Install Homebrew" && return 0
    info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    brew="$(find_brew)" || fail "Homebrew installation failed."
    info "Homebrew installed"
  fi

  skip_step "Install Apps and CLIs" && return 0
  if [[ -f "$BREWFILE" ]]; then
    info "Running brew bundle..."
    warn "This may take a while. Time for coffee!"
    "$brew" bundle --file "$BREWFILE"
    info "Homebrew bundle installed"
  else
    warn "Brewfile not found at: $BREWFILE"
  fi
}

backup() {
  header "🍺 Backup Homebrew"
  local brew new_brewfile="${BREWFILE}.new"
  brew="$(find_brew)" || fail "Homebrew is not installed."

  info "Running brew bundle dump..."
  "$brew" bundle dump --force --file "$new_brewfile"
  info "$new_brewfile created"

  info "Sorting both Brewfiles in place..."
  sort "$BREWFILE" -o "$BREWFILE"
  sort "$new_brewfile" -o "$new_brewfile"

  warn "VS Code will now open to compare both files"
  info "1. Left: installed packages (read-only); right: Brewfile"
  info "2. Update the Brewfile on the right with new packages or remove unneeded ones"
  info "3. Save the Brewfile ($new_brewfile will be deleted)"
  info "4. Close the diff tab and return here to continue"
  pause "Press Enter to open VS Code..."

  # VS Code makes the left side of a diff read-only by default, so the Brewfile goes on the editable right side.
  code --diff "$new_brewfile" "$BREWFILE" --wait
  rm -f "$new_brewfile"
  info "Brewfile comparison complete"
}

case "${1:-}" in
  setup) setup ;;
  backup) backup ;;
  *) usage "setup|backup" ;;
esac
