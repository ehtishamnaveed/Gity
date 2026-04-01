#!/usr/bin/env bash

set -e

INSTALL_DIR="$HOME/.local/bin"
SCRIPT_NAME="gity"
OS=""
REPO_URL="https://raw.githubusercontent.com/ehtishamnaveed/Gity/master"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# ============================================================
# DETECT OS
# ============================================================

detect_os() {
    local uname_s
    uname_s="$(uname -s)"
    
    case "$uname_s" in
        Darwin*)
            OS="macos"
            ;;
        Linux*)
            if grep -qi microsoft /proc/version 2>/dev/null; then
                OS="windows" # WSL
            else
                OS="linux"
            fi
            ;;
        MINGW*|MSYS*|CYGWIN*)
            OS="windows"
            ;;
        *)
            OS="unknown"
            ;;
    esac
}

# ============================================================
# INSTALL DEPENDENCIES
# ============================================================

install_deps() {
    local deps="git fzf lazygit"
    
    case "$OS" in
        macos)
            echo -e "${BLUE}==> Detected macOS${NC}"
            
            # Check for Homebrew
            if ! command -v brew &>/dev/null; then
                echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            fi
            
            echo -e "${BLUE}==> Installing dependencies via Homebrew...${NC}"
            for dep in $deps; do
                if ! command -v "$dep" &>/dev/null; then
                    echo -e "    Installing $dep..."
                    brew install "$dep"
                else
                    echo -e "${GREEN}    ✓ $dep already installed${NC}"
                fi
            done
            
            # Optional: gh CLI
            if ! command -v gh &>/dev/null; then
                echo -e "    Installing gh CLI (optional)..."
                brew install gh || echo -e "${YELLOW}    [!] Optional gh CLI failed to install${NC}"
            fi
            ;;
        
        linux)
            echo -e "${BLUE}==> Detected Linux${NC}"
            
            local cmd=""
            if command -v pacman &>/dev/null; then
                cmd="sudo pacman -S --noconfirm"
            elif command -v apt-get &>/dev/null; then
                sudo apt-get update -qq
                cmd="sudo apt-get install -y"
            elif command -v dnf &>/dev/null; then
                cmd="sudo dnf install -y"
            elif command -v yum &>/dev/null; then
                cmd="sudo yum install -y"
            elif command -v zypper &>/dev/null; then
                cmd="sudo zypper install -y"
            fi
            
            if [ -n "$cmd" ]; then
                echo -e "${BLUE}==> Installing dependencies via system package manager...${NC}"
                for dep in $deps; do
                    if ! command -v "$dep" &>/dev/null; then
                        echo -e "    Installing $dep..."
                        $cmd "$dep" || echo -e "${RED}    ✗ Failed to install $dep${NC}"
                    else
                        echo -e "${GREEN}    ✓ $dep already installed${NC}"
                    fi
                done
            else
                echo -e "${YELLOW}[!] Unknown distro — please install manually: $deps${NC}"
            fi
            ;;
        
        windows)
            echo -e "${BLUE}==> Detected Windows (Git Bash / WSL)${NC}"
            echo -e "${YELLOW}    For the best experience on Windows, please use the PowerShell installer:${NC}"
            echo ""
            echo -e "    ${GREEN}irm https://raw.githubusercontent.com/ehtishamnaveed/Gity/master/install.ps1 | iex${NC}"
            echo ""
            echo "    This will install all dependencies natively on Windows."
            echo ""
            
            # Allow fallback installation for Git Bash users if they really want it
            if [[ "$(uname -s)" == *"MINGW"* ]] || [[ "$(uname -s)" == *"MSYS"* ]]; then
                 echo -e "${BLUE}==> Continuing with Git Bash installation...${NC}"
                 # Add Git Bash specific dependency checks/installs if needed
                 # Usually users in Git Bash already have git.
            fi
            ;;
    esac
}

# ============================================================
# DOWNLOAD & INSTALL GITY
# ============================================================

install_gity() {
    # If we are on pure Windows (not WSL) and using this script, we still want to install the .sh
    # But the new upstream version seems to prefer the .ps1 for Windows.
    # We will install gity.sh to ~/.local/bin for unix-like environments.
    
    echo -e "${BLUE}==> Installing Gity...${NC}"
    mkdir -p "$INSTALL_DIR"
    
    if [ -f "./gity.sh" ]; then
        cp ./gity.sh "$INSTALL_DIR/$SCRIPT_NAME"
    else
        echo -e "    Downloading from $REPO_URL/gity.sh..."
        curl -sSL "$REPO_URL/gity.sh" -o "$INSTALL_DIR/$SCRIPT_NAME"
    fi
    
    chmod +x "$INSTALL_DIR/$SCRIPT_NAME"
    echo -e "${GREEN}==> Installed to $INSTALL_DIR/$SCRIPT_NAME${NC}"
}

# ============================================================
# SETUP PATH
# ============================================================

setup_path() {
    local shell_rc=""
    case "$SHELL" in
        */bash)
            shell_rc="$HOME/.bashrc"
            [ ! -f "$shell_rc" ] && shell_rc="$HOME/.bash_profile"
            ;;
        */zsh)
            shell_rc="$HOME/.zshrc"
            ;;
        */fish)
            shell_rc="$HOME/.config/fish/config.fish"
            ;;
    esac
    
    if [ -n "$shell_rc" ] && [ -f "$shell_rc" ]; then
        if ! grep -q "$INSTALL_DIR" "$shell_rc" 2>/dev/null; then
            echo "" >> "$shell_rc"
            echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$shell_rc"
            echo -e "${GREEN}==> Added $INSTALL_DIR to PATH in $shell_rc${NC}"
            echo -e "${YELLOW}    Please restart your terminal or run: source $shell_rc${NC}"
        else
            echo -e "${GREEN}==> $INSTALL_DIR already in PATH${NC}"
        fi
    fi
}

# ============================================================
# MAIN
# ============================================================

echo -e "${BLUE}"
echo "========================================"
echo "  GITY - Installer v1.0.0"
echo "========================================"
echo -e "${NC}"

detect_os
install_deps
install_gity
setup_path

echo ""
echo -e "${GREEN}========================================"
echo "  INSTALLATION COMPLETE"
echo "========================================"
echo -e "${NC}"
echo "To run Gity:"
echo -e "  ${GREEN}gity${NC}"
echo ""
