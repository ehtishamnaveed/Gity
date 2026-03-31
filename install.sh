#!/bin/bash

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

is_windows_shell() {
    case "$(uname -s)" in
        *Msys*|*MINGW*|*CYGWIN*) return 0 ;;
        Linux)
            grep -qi microsoft /proc/version 2>/dev/null && return 0
            ;;
    esac
    return 1
}

if is_windows_shell; then
    INSTALL_TARGET="$HOME/gity"
else
    INSTALL_TARGET="$HOME/.local/bin/gity"
fi
REQUIRED_PACKAGES="git fzf lazygit"
OPTIONAL_PACKAGES=""
CLIPBOARD_PACKAGES="xclip xsel wl-copy"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

banner() {
    echo -e "${BLUE}"
    echo "  ██████╗ ██████╗ ███████╗██╗██████╗ ██╗ █████╗ ███╗   ██╗"
    echo "  ██╔══██╗██╔══██╗██╔════╝██║██╔══██╗██║██╔══██╗████╗  ██║"
    echo "  ██████╔╝██████╔╝███████╗██║██║  ██║██║███████║██╔██╗ ██║"
    echo "  ██╔═══╝ ██╔══██╗╚════██║██║██║  ██║██║██╔══██║██║╚██╗██║"
    echo "  ██║     ██║  ██║███████║██║██████╔╝██║██║  ██║██║ ╚████║"
    echo "  ╚═╝     ╚═╝  ╚═╝╚══════╝╚═╝╚═════╝ ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝"
    echo -e "  ${NC}GITY - Installer"
    echo ""
}

detect_distro() {
    local uname_s
    uname_s="$(uname -s)"

    if [ "$uname_s" == "Darwin" ]; then
        DISTRO="macos"
    elif [ "$uname_s" == "Linux" ]; then
        if grep -qi microsoft /proc/version 2>/dev/null; then
            DISTRO="wsl"
        elif [ -f /etc/os-release ]; then
            . /etc/os-release
            DISTRO="$ID"
        elif [ -f /etc/arch-release ]; then
            DISTRO="arch"
        elif [ -f /etc/debian_version ]; then
            DISTRO="debian"
        elif [ -f /etc/fedora-release ]; then
            DISTRO="fedora"
        elif [ -x /bin/zypper ]; then
            DISTRO="opensuse"
        elif [ -x /bin/xbps-install ]; then
            DISTRO="void"
        else
            DISTRO="linux"
        fi
    elif [[ "$uname_s" == *"Msys"* || "$uname_s" == *"MINGW"* || "$uname_s" == *"CYGWIN"* ]]; then
        DISTRO="windows"
    else
        DISTRO="unknown"
    fi
}

get_install_cmd() {
    detect_distro
    case "$DISTRO" in
        arch)
            echo "sudo pacman -S --noconfirm"
            ;;
        debian|ubuntu|linuxmint|pop|wsl)
            echo "sudo apt install -y"
            ;;
        fedora|rhel|centos)
            echo "sudo dnf install -y"
            ;;
        opensuse|opensuse-tumbleweed|opensuse-leap)
            echo "sudo zypper install -y"
            ;;
        void)
            echo "sudo xbps-install -y"
            ;;
        macos)
            echo "brew install"
            ;;
        windows)
            if command -v scoop &>/dev/null; then
                echo "scoop install"
            elif command -v choco &>/dev/null; then
                echo "choco install -y"
            elif command -v winget &>/dev/null; then
                echo "winget install -e"
            else
                echo ""
            fi
            ;;
        *)
            echo ""
            ;;
    esac
}

install_package() {
    local pkg="$1"
    local cmd
    cmd=$(get_install_cmd)

    if [ -z "$cmd" ]; then
        echo -e "${YELLOW}  [!] Unknown distro — cannot auto-install $pkg${NC}"
        echo -e "${YELLOW}     Please install '$pkg' manually and re-run this script.${NC}"
        return 1
    fi

    echo -e "${BLUE}  â Installing $pkg via ${cmd%% *} ${NC}"
    if eval "$cmd $pkg" 2>/dev/null; then
        echo -e "${GREEN}  ✓ $pkg installed${NC}"
        return 0
    else
        echo -e "${RED}  ✗ Failed to install $pkg${NC}"
        return 1
    fi
}

check_installed() {
    command -v "$1" &>/dev/null
}

check_and_install() {
    local pkg="$1"
    local label="${2:-$pkg}"

    if check_installed "$pkg"; then
        echo -e "${GREEN}  ✓ $label${NC}"
        return 0
    else
        echo -e "${YELLOW}  ○ $label not found${NC}"
        install_package "$pkg"
        return $?
    fi
}

setup_path() {
    local profile_files=("$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile")
    local path_line='export PATH="$HOME/.local/bin:$PATH"'
    local found=0

    for pf in "${profile_files[@]}"; do
        if [ -f "$pf" ]; then
            if ! grep -q "\.local/bin" "$pf" 2>/dev/null; then
                echo "" >> "$pf"
                echo "# Added by gity installer" >> "$pf"
                echo "$path_line" >> "$pf"
                echo -e "${GREEN}  ✓ Added PATH to $pf${NC}"
            fi
            found=1
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo -e "${YELLOW}  [!] No shell profile found — please add this to your shell config:${NC}"
        echo -e "${YELLOW}     $path_line${NC}"
    fi

    export PATH="$HOME/.local/bin:$PATH"
}

setup_path_windows() {
    local profile_files=("$HOME/.bashrc" "$HOME/.bash_profile" "$HOME/.profile")
    local path_line='export PATH="$HOME:$PATH"'
    local found=0

    if command -v scoop &>/dev/null; then
        local scoop_shims
        scoop_shims=$(scoop config home 2>/dev/null || echo "$HOME/scoop")/shims
        path_line="export PATH=\"$scoop_shims:\$PATH\""
        mkdir -p "$scoop_shims"
    fi

    for pf in "${profile_files[@]}"; do
        if [ -f "$pf" ]; then
            if ! grep -q "gity" "$pf" 2>/dev/null; then
                echo "" >> "$pf"
                echo "# Added by gity installer" >> "$pf"
                echo "$path_line" >> "$pf"
                echo -e "${GREEN}  ✓ Added PATH to $pf${NC}"
            fi
            found=1
        fi
    done

    if [ "$found" -eq 0 ]; then
        echo -e "${YELLOW}  [!] No shell profile found — please add this to your PATH:${NC}"
        echo -e "${YELLOW}     $path_line${NC}"
    fi
}

detect_clipboard() {
    local win_clip="clip.exe"
    for tool in xclip xsel wl-copy "$win_clip" clip; do
        if check_installed "$tool"; then
            echo "$tool"
            return 0
        fi
    done
    echo ""
}

banner

echo -e "${BLUE}[*] Detecting system...${NC}"
detect_distro
echo -e "${BLUE}  → Distro: ${DISTRO}${NC}"

if [ -z "$(get_install_cmd)" ]; then
    echo -e "${RED}[!] Unsupported distribution: $DISTRO${NC}"
    echo -e "${YELLOW}    Please install manually: git, fzf, lazygit${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[*] Checking required dependencies...${NC}"
failed=0

for pkg in $REQUIRED_PACKAGES; do
    check_and_install "$pkg" || failed=1
done

echo ""
echo -e "${BLUE}[*] Checking optional clipboard tools...${NC}"
CLIPBOARD_TOOL=$(detect_clipboard)
if [ -n "$CLIPBOARD_TOOL" ]; then
    echo -e "${GREEN}  ✓ Clipboard tool: $CLIPBOARD_TOOL${NC}"
else
    echo -e "${YELLOW}  ○ No clipboard tool found — copy feature will be disabled${NC}"
fi

if [ "$failed" -eq 1 ]; then
    echo ""
    echo -e "${RED}[!] Some required packages failed to install.${NC}"
    echo -e "${YELLOW}    Please install them manually and re-run.${NC}"
    exit 1
fi

echo ""
echo -e "${BLUE}[*] Setting up PATH...${NC}"
if is_windows_shell; then
    setup_path_windows
else
    setup_path
fi

echo ""
echo -e "${BLUE}[*] Installing gity...${NC}"
if is_windows_shell; then
    cp "$SCRIPT_DIR/gity.sh" "$INSTALL_TARGET"
    chmod +x "$INSTALL_TARGET"
    echo -e "${GREEN}  ✓ Installed to $INSTALL_TARGET${NC}"
    echo -e "${YELLOW}  NOTE: Add '$HOME' to your PATH if 'gity' is not found.${NC}"
else
    mkdir -p "$HOME/.local/bin"
    cp "$SCRIPT_DIR/gity.sh" "$INSTALL_TARGET"
    chmod +x "$INSTALL_TARGET"
    echo -e "${GREEN}  ✓ Installed to $INSTALL_TARGET${NC}"
fi

echo ""
echo -e "${BLUE}[*] Creating cache directory...${NC}"
mkdir -p "$HOME/.cache"
echo -e "${GREEN}  ✓ Cache directory ready${NC}"

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  Installation complete!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo -e "  Run it with: ${GREEN}gity${NC}"
echo ""
if is_windows_shell; then
    echo -e "${YELLOW}  NOTE: Restart your terminal or run: source ~/.bashrc${NC}"
else
    echo -e "${YELLOW}  NOTE: Restart your terminal or run: source ~/.bashrc (or ~/.zshrc)${NC}"
fi
echo ""
