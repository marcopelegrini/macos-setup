#!/usr/bin/env bash

# macOS Setup CLI
# Automates backup and setup processes for macOS

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_PATH="${HOME}/OSX/dotfiles"

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

skip_step() {
    local step_name="$1"
    echo -e "${YELLOW}Press any key within 5 seconds to skip this step...${NC}"

    if read -t 5 -n 1 -s; then
        echo ""
        print_warning "Skipping: $step_name"
        return 0
    else
        echo ""
        return 1
    fi
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
    if ! command -v mackup &> /dev/null || [[ ! -f "${HOME}/.mackup.cfg" ]]; then
        print_warning "Mackup is not installed or config not found at ~/.mackup.cfg"
        exit 1
    else
        mackup backup
        print_success "Mackup backup complete"
        echo ""
        print_info "Mackup files backed up to location specified in ~/.mackup.cfg"
        print_warning "Remember to store the mackup folder somewhere safe!"
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
    print_warning "Parts of the workflow might be required to run as sudo, so your passworkd may be requested multiple times."
    echo ""
    print_info "This workflow will:"
    echo "  • Configure passwordless sudo"
    echo "  • Install dotfiles"
    echo "  • Install Homebrew, Apps and CLIs (brew bundle)"
    echo "  • Install Mac App Store apps using mas-cli"
    echo "  • Configure Dock"
    echo "  • Restore Mackup backups"
    echo "  • Prompt for Raycast restore"
    echo "  • Apply macOS settings"
    echo ""

    if ! confirm "Continue with setup?"; then
        print_warning "Setup cancelled"
        exit 0
    fi

    print_header "[1/9] Configure Passwordless Sudo"
    if ! skip_step "Configure Passwordless Sudo"; then
        local sudoers_file="/etc/sudoers.d/admin_nopasswd"
        echo "%admin ALL=(ALL) NOPASSWD: ALL" | sudo tee "$sudoers_file" > /dev/null
        sudo chmod 0440 "$sudoers_file"

        if sudo visudo -c -f "$sudoers_file" &> /dev/null; then
            print_success "Passwordless sudo configured successfully"
            print_info "Configuration saved to: $sudoers_file"
        else
            print_error "Sudoers syntax validation failed"
            sudo rm -f "$sudoers_file"
            print_error "Configuration removed for safety"
        fi
    fi

    print_header "[2/9] Install Dotfiles"
    if ! skip_step "Install Dotfiles"; then
        if [[ ! -d "$DOTFILES_PATH" ]]; then
            print_error "Dotfiles directory not found at: $DOTFILES_PATH"
            print_info "Please ensure dotfiles are available before running setup, skipping"
        else
            bash "${SCRIPT_DIR}/dotfiles.sh"
            print_success "Dotfiles installed"
        fi
    fi

    print_header "[3/9] Install Homebrew, apps and CLIs"
    if command -v brew &> /dev/null; then
        print_success "Homebrew already installed"
    else
        if ! skip_step "Install Homebrew"; then
            print_info "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

            # Add Homebrew to PATH for Apple Silicon Macs
            if [[ -f "/opt/homebrew/bin/brew" ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            fi

            if command -v brew &> /dev/null; then
                print_success "Homebrew installed"

                if ! skip_step "Install Apps and CLIs"; then
                    if [[ -f "${SCRIPT_DIR}/Brewfile" ]]; then
                        print_info "Running brew bundle..."
                        print_warning "This may take a while. Time for coffee! ☕"
                        cd "${SCRIPT_DIR}"
                        brew bundle
                        print_success "Homebrew bundle installed"
                    fi
                fi
            else
                print_error "Homebrew installation failed"
                exit 1
            fi
        fi
    fi

    print_header "[4/9] App Store Apps"
    if ! command -v mas &> /dev/null; then
        print_warning "mas-cli is not installed. Skipping App Store apps."
    else
        if ! skip_step "Install App Store Apps (requires manual authentication)?"; then
            print_info "Please open the App Store and sign in with your Apple ID"
            read -p "Press Enter when signed in..."
            bash "${SCRIPT_DIR}/mas.sh"
            print_success "Mac App Store apps installed"    
        fi
    fi

    print_header "[5/9] Configure Dock"
    if ! skip_step "Configure Dock"; then
        bash "${SCRIPT_DIR}/dock.sh"
        print_success "Dock configured"
    fi

    print_header "[6/9] Restore Mackup Backups"
    if ! skip_step "Restore Mackup Backups"; then
        if [[ ! -d "${SCRIPT_DIR}/mackup" ]] || ! command -v mackup &> /dev/null || [[ ! -f "${HOME}/.mackup.cfg" ]]; then
            print_warning "Skipping Mackup restore - prerequisites not met"
        else
            mackup restore
            print_success "Mackup restored"
        fi
    fi

    print_header "[7/9] Restore Raycast Backup"
    if ! skip_step "Restore Raycast Backup"; then
        print_info "Raycast > Preferences > Advanced > Import Settings"
        read -p "Press Enter when done..."
        print_success "Raycast backup confirmed"
    fi

    print_header "[8/9] Apply macOS Settings"
    if ! skip_step "Apply macOS Settings"; then
        sudo bash "${SCRIPT_DIR}/osx.sh"
        print_success "macOS settings applied"
    fi

    print_header "[9/9] Restart Required"
    print_warning "A restart is required for settings to take effect"
    if ! skip_step "macOS restart"; then
        sudo shutdown -r now
    else
        print_warning "Please restart manually before continuing"
    fi
}

main() {
    if [[ "$(uname)" != "Darwin" ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi

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

main "$@"
