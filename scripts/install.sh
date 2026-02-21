#!/bin/bash

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logo
print_logo() {
    echo -e "${CYAN}"
    cat << "EOF"
   ██████╗██╗   ██╗██████╗ ███████╗ ██████╗ ██████╗      ██████╗ ██████╗  ██████╗   
  ██╔════╝██║   ██║██╔══██╗██╔════╝██╔═══██╗██╔══██╗     ██╔══██╗██╔══██╗██╔═══██╗  
  ██║     ██║   ██║██████╔╝███████╗██║   ██║██████╔╝     ██████╔╝██████╔╝██║   ██║  
  ██║     ██║   ██║██╔══██╗╚════██║██║   ██║██╔══██╗     ██╔═══╝ ██╔══██╗██║   ██║  
  ╚██████╗╚██████╔╝██║  ██║███████║╚██████╔╝██║  ██║     ██║     ██║  ██║╚██████╔╝  
   ╚═════╝ ╚═════╝ ╚═╝  ╚═╝╚══════╝ ╚═════╝ ╚═╝  ╚═╝     ╚═╝     ╚═╝  ╚═╝ ╚═════╝  
EOF
    echo -e "${NC}"
}

# Get download folder path
get_downloads_dir() {
    if [[ "$(uname)" == "Darwin" ]]; then
        echo "$HOME/Downloads"
    else
        if [ -f "$HOME/.config/user-dirs.dirs" ]; then
            . "$HOME/.config/user-dirs.dirs"
            echo "${XDG_DOWNLOAD_DIR:-$HOME/Downloads}"
        else
            echo "$HOME/Downloads"
        fi
    fi
}

# Get latest version
get_latest_version() {
    echo -e "${CYAN}ℹ️ Checking latest version...${NC}"
    latest_release=$(curl -s https://api.github.com/repos/aadityaaggarwal-glitch/Cursor-Vip/releases/latest) || {
        echo -e "${RED}❌ Cannot get latest version information${NC}"
        exit 1
    }
    
    VERSION=$(echo "$latest_release" | grep -o '"tag_name": ".*"' | cut -d'"' -f4 | tr -d 'v')
    if [ -z "$VERSION" ]; then
        echo -e "${RED}❌ Failed to parse version from GitHub API response:\n${latest_release}"
        exit 1
    fi

    echo -e "${GREEN}✅ Found latest version: ${VERSION}${NC}"
}

# Detect system type and architecture
detect_os() {
    if [[ "$(uname)" == "Darwin" ]]; then
        # Detect macOS architecture
        ARCH=$(uname -m)
        if [[ "$ARCH" == "arm64" ]]; then
            OS="mac_arm64"
            echo -e "${CYAN}ℹ️ Detected macOS ARM64 architecture${NC}"
        else
            OS="mac_intel"
            echo -e "${CYAN}ℹ️ Detected macOS Intel architecture${NC}"
        fi
    elif [[ "$(uname)" == "Linux" ]]; then
        # Detect Linux architecture
        ARCH=$(uname -m)
        if [[ "$ARCH" == "aarch64" || "$ARCH" == "arm64" ]]; then
            OS="linux_arm64"
            echo -e "${CYAN}ℹ️ Detected Linux ARM64 architecture${NC}"
        else
            OS="linux_x64"
            echo -e "${CYAN}ℹ️ Detected Linux x64 architecture${NC}"
        fi
    else
        # Assume Windows
        OS="windows"
        echo -e "${CYAN}ℹ️ Detected Windows system${NC}"
    fi
}

install_cursor_free_vip() {
    local downloads_dir
    downloads_dir=$(get_downloads_dir)

    local archive_name="Cursor-Vip-${VERSION}.tar.gz"
    local archive_path="${downloads_dir}/${archive_name}"

    local download_url="https://github.com/aadityaaggarwal-glitch/Cursor-Vip/archive/refs/tags/${VERSION}.tar.gz"

    echo -e "${CYAN}ℹ️ Downloading source code...${NC}"
    echo -e "${CYAN}ℹ️ ${download_url}${NC}"

    if ! curl -L -o "${archive_path}" "${download_url}"; then
        echo -e "${RED}❌ Failed to download source archive${NC}"
        exit 1
    fi

    echo -e "${GREEN}✅ Source archive downloaded${NC}"

    cd "${downloads_dir}" || exit 1
    tar -xzf "${archive_name}"

    local project_dir="Cursor-Vip-${VERSION}"
    cd "${project_dir}" || {
        echo -e "${RED}❌ Failed to enter project directory${NC}"
        exit 1
    }

    echo -e "${GREEN}✅ Source extracted to ${PWD}${NC}"

    # -------------------------------
    # AUTO-DETECT HOW TO RUN PROJECT
    # -------------------------------

    if [ -f "package.json" ]; then
        echo -e "${CYAN}ℹ️ Detected Node.js project${NC}"
        command -v npm >/dev/null 2>&1 || {
            echo -e "${RED}❌ npm is required but not installed${NC}"
            exit 1
        }
        npm install
        npm start
        return
    fi

    if [ -f "requirements.txt" ]; then
        echo -e "${CYAN}ℹ️ Detected Python project${NC}"
        python3 -m venv venv
        source venv/bin/activate
        pip install -r requirements.txt
        python main.py
        return
    fi

    if [ -f "main.sh" ]; then
        echo -e "${CYAN}ℹ️ Detected shell script entry point${NC}"
        chmod +x main.sh
        ./main.sh
        return
    fi

    echo -e "${YELLOW}⚠️ Project downloaded but no known entry point found${NC}"
    echo -e "${YELLOW}⚠️ Please run it manually from:${NC} ${PWD}"
}

# Main program
main() {
    print_logo
    get_latest_version
    detect_os
    install_cursor_free_vip
}

# Run main program
main 
