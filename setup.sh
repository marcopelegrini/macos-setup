#!/usr/bin/env bash

# macOS Setup CLI
# Automates backup and setup processes for macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Default dotfiles path
DOTFILES_PATH="${HOME}/OSX/dotfiles"

# Helper functions
print_header() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ $1${NC}"
}

confirm() {
    read -p "$1 [y/N]: " -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

usage() {
    cat << EOF
macOS Setup CLI

Usage: $(basename "$0") <command>

Commands:
  setup     Run the full macOS setup workflow
  backup    Backup current macOS configuration (coming soon)

Examples:
  $(basename "$0") setup
  $(basename "$0") backup

EOF
    exit 1
}

# Workflow: Backup
run_backup() {
    print_header "macOS Backup Workflow"
    print_warning "This will backup your current macOS configuration"

    print_header "[1/4] Dump Homebrew Bundle"
    print_info "Running brew bundle dump..."
    cd "${SCRIPT_DIR}"
    brew bundle dump --file=Brewfile.new
    print_success "Brewfile.new created"

    print_header "[2/4] Compare Brewfiles"
    print_info "Sorting both Brewfiles in place..."
    sort "${SCRIPT_DIR}/Brewfile" -o "${SCRIPT_DIR}/Brewfile"
    sort "${SCRIPT_DIR}/Brewfile.new" -o "${SCRIPT_DIR}/Brewfile.new"

    echo ""
    print_warning "VSCode will now open to compare both files"
    print_info "Instructions:"
    echo "  1. Review differences between old and new Brewfile"
    echo "  2. Update Brewfile with new packages or remove unneeded ones"
    echo "  3. Save the Brewfile (Brewfile.new) will be deleted"
    echo "  4. Close VSCode and return here to continue"
    echo ""
    read -p "Press Enter to open VSCode..."

    code --diff "${SCRIPT_DIR}/Brewfile" "${SCRIPT_DIR}/Brewfile.new" --wait

    rm "${SCRIPT_DIR}/Brewfile.new"
    print_success "Brewfile comparison complete"


    print_header "[3/4] Backup Mackup"
    if ! command -v mackup &> /dev/null; then
        print_warning "Mackup is not installed. Skipping mackup backup."
    else
        if [[ ! -f "${HOME}/.mackup.cfg" ]]; then
            print_warning "Mackup config not found at ~/.mackup.cfg"
            print_info "Skipping mackup backup"
        else
            print_info "Running mackup backup..."
            mackup backup
            print_success "Mackup backup complete"
            echo ""
            print_info "Mackup files backed up to location specified in ~/.mackup.cfg"
            print_warning "Remember to store the mackup folder somewhere safe!"
        fi
    fi

    print_header "[4/4] Backup Raycast"
    print_info "Backup Raycast settings manually:"
    echo "  1. Open Raycast"
    echo "  2. Go to Preferences > Advanced"
    echo "  3. Click 'Export Settings'"
    echo "  4. Save the backup file"
    echo ""
    read -p "Press Enter when done..."
    print_success "Raycast backup confirmed"

    print_header "Backup Complete!"
    print_success "Your macOS backup is complete!"
    echo ""
    print_info "Next steps:"
    echo "  • Commit and push the updated Brewfile to Git"
    echo "  • Store mackup backup folder safely (NAS, cloud, etc.)"
    echo "  • Store Raycast backup file safely"
}

# Workflow: Setup
run_setup() {
    print_header "macOS Setup Workflow"
    print_warning "This will setup your new macOS installation"
    echo ""
    print_info "This workflow will:"
    echo "  • Install dotfiles"
    echo "  • Prompt for App Store authentication"
    echo "  • Install Mac App Store apps (mas.sh)"
    echo "  • Apply macOS settings (osx.sh)"
    echo "  • Restart your Mac"
    echo "  • Install Homebrew"
    echo "  • Install apps and CLIs (brew bundle)"
    echo "  • Configure Dock (dock.sh)"
    echo "  • Restore Mackup backups"
    echo "  • Prompt for Raycast restore"
    echo ""

    if ! confirm "Continue with setup?"; then
        print_warning "Setup cancelled"
        exit 0
    fi

    print_header "[1/10] Install Dotfiles"
    if [[ ! -d "$DOTFILES_PATH" ]]; then
        print_error "Dotfiles directory not found at: $DOTFILES_PATH"
        print_info "Please ensure dotfiles are available before running setup"
        exit 1
    fi

    if [[ ! -f "${SCRIPT_DIR}/dotfiles.sh" ]]; then
        print_error "dotfiles.sh script not found"
        exit 1
    fi

    print_info "Running dotfiles.sh..."
    bash "${SCRIPT_DIR}/dotfiles.sh"
    print_success "Dotfiles installed"

    print_header "[2/10] App Store Authentication"
    print_info "Please open the App Store and sign in with your Apple ID"
    read -p "Press Enter when signed in..."

    print_header "[3/10] Install Mac App Store Apps"
    if [[ -f "${SCRIPT_DIR}/mas.sh" ]]; then
        print_info "Running mas.sh..."
        bash "${SCRIPT_DIR}/mas.sh"
        print_success "Mac App Store apps installed"
    fi

    print_header "[4/10] Apply macOS Settings"
    if [[ -f "${SCRIPT_DIR}/osx.sh" ]]; then
        print_warning "This will modify system settings"
        if confirm "Apply macOS settings?"; then
            bash "${SCRIPT_DIR}/osx.sh"
            print_success "macOS settings applied"
        fi
    fi

    print_header "[5/10] Restart Required"
    print_warning "A restart is required for settings to take effect"
    if confirm "Restart now?"; then
        print_info "Restarting in 5 seconds... (Press Ctrl+C to cancel)"
        sleep 5
        sudo shutdown -r now
        exit 0
    else
        print_warning "Please restart manually before continuing"
        if ! confirm "Have you already restarted and want to continue?"; then
            print_info "Setup paused. Run './setup.sh setup' after restarting"
            exit 0
        fi
    fi

    print_header "[6/10] Install Homebrew"
    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed"
    else
        print_info "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for Apple Silicon Macs
        if [[ -f "/opt/homebrew/bin/brew" ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi

        if command -v brew &> /dev/null; then
            print_success "Homebrew installed"
        else
            print_error "Homebrew installation failed"
            exit 1
        fi
    fi

    print_header "[7/10] Install Apps and CLIs"
    if [[ -f "${SCRIPT_DIR}/Brewfile" ]]; then
        print_info "Running brew bundle..."
        print_warning "This may take a while. Time for coffee! ☕"
        cd "${SCRIPT_DIR}"
        brew bundle
        print_success "Homebrew bundle installed"
    fi

    print_header "[8/10] Configure Dock"
    if [[ -f "${SCRIPT_DIR}/dock.sh" ]]; then
        print_info "Running dock.sh..."
        bash "${SCRIPT_DIR}/dock.sh"
        print_success "Dock configured"
    fi

    print_header "[9/10] Restore Mackup Backups"
    if [[ ! -d "${SCRIPT_DIR}/mackup" ]]; then
        print_error "Mackup folder not found at: ${SCRIPT_DIR}/mackup"
        print_info "Please ensure mackup backup folder is available before restoring"
        exit 1
    fi

    if ! command -v mackup &> /dev/null; then
        print_error "Mackup is not installed"
        exit 1
    fi

    if [[ ! -f "${HOME}/.mackup.cfg" ]]; then
        print_error "Mackup config not found at ~/.mackup.cfg"
        exit 1
    fi

    print_warning "This will restore application settings from your backup"
    if confirm "Run mackup restore?"; then
        mackup restore
        print_success "Mackup restored"
    else
        print_warning "Skipped Mackup restore"
    fi

    print_header "[10/10] Restore Raycast Backup"
    print_info "Restore Raycast backup manually:"
    print_info "Raycast > Preferences > Advanced > Import Settings"
    read -p "Press Enter when done..."
    print_success "Raycast backup confirmed"

    print_header "Setup Complete!"
    print_success "Your macOS setup is complete!"
}

# Main
main() {
    # Check if running on macOS
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi

    # Exit if not running as root
    if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Please use: sudo $0"
    exit 1
    fi

    # Parse command
    case "${1:-}" in
        setup)
            run_setup
            ;;
        backup)
            run_backup
            ;;
        *)
            usage
            ;;
    esac
}

# Run
main "$@"
