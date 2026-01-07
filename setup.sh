#!/bin/bash

# Dotfiles setup script
# Works on both Linux and macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get the directory where this script is located
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS="Linux";;
        Darwin*)    OS="macOS";;
        *)          OS="Unknown";;
    esac
    echo -e "${BLUE}Detected OS: ${OS}${NC}"
}

# Backup existing file if it exists and is not a symlink
backup_file() {
    local target="$1"
    if [ -e "$target" ] && [ ! -L "$target" ]; then
        local backup="${target}.backup"
        echo -e "${YELLOW}Backing up existing ${target} to ${backup}${NC}"
        mv "$target" "$backup"
    elif [ -L "$target" ]; then
        echo -e "${YELLOW}Removing existing symlink ${target}${NC}"
        rm "$target"
    fi
}

# Create symlink
create_symlink() {
    local source="$1"
    local target="$2"

    # Create parent directory if it doesn't exist
    local target_dir="$(dirname "$target")"
    if [ ! -d "$target_dir" ]; then
        echo -e "${BLUE}Creating directory ${target_dir}${NC}"
        mkdir -p "$target_dir"
    fi

    # Backup existing file
    backup_file "$target"

    # Create symlink
    echo -e "${GREEN}Creating symlink: ${target} -> ${source}${NC}"
    ln -s "$source" "$target"
}

# Check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Install Homebrew on macOS if not installed
install_homebrew() {
    if ! command_exists brew; then
        echo -e "${YELLOW}Homebrew is not installed.${NC}"
        read -p "Would you like to install Homebrew? (y/n): " install_brew
        if [[ "$install_brew" =~ ^[Yy]$ ]]; then
            echo -e "${BLUE}Installing Homebrew...${NC}"
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            # Add Homebrew to PATH for this session
            if [[ -f /opt/homebrew/bin/brew ]]; then
                eval "$(/opt/homebrew/bin/brew shellenv)"
            elif [[ -f /usr/local/bin/brew ]]; then
                eval "$(/usr/local/bin/brew shellenv)"
            fi
            echo -e "${GREEN}Homebrew installed successfully!${NC}"
        else
            echo -e "${RED}Homebrew is required for macOS package installation. Skipping dependency installation.${NC}"
            return 1
        fi
    fi
    return 0
}

# Install zsh
install_zsh() {
    if command_exists zsh; then
        echo -e "${GREEN}zsh is already installed.${NC}"
        return 0
    fi

    echo -e "${BLUE}Installing zsh...${NC}"
    if [[ "$OS" == "Linux" ]]; then
        sudo apt-get update
        sudo apt-get install -y zsh
    elif [[ "$OS" == "macOS" ]]; then
        brew install zsh
    fi
    echo -e "${GREEN}zsh installed successfully!${NC}"
}

# Install git and curl (Linux only, usually pre-installed on macOS)
install_git_curl() {
    if [[ "$OS" == "Linux" ]]; then
        echo -e "${BLUE}Installing git and curl...${NC}"
        sudo apt-get update
        sudo apt-get install -y git curl
        echo -e "${GREEN}git and curl installed successfully!${NC}"
    fi
}

# Set zsh as default shell
set_default_shell() {
    local zsh_path
    zsh_path=$(which zsh)

    if [[ "$SHELL" == *"zsh"* ]]; then
        echo -e "${GREEN}zsh is already the default shell.${NC}"
        return 0
    fi

    echo -e "${BLUE}Setting zsh as default shell...${NC}"

    # Add zsh to /etc/shells if not already there
    if ! grep -q "$zsh_path" /etc/shells; then
        echo -e "${YELLOW}Adding $zsh_path to /etc/shells...${NC}"
        echo "$zsh_path" | sudo tee -a /etc/shells
    fi

    chsh -s "$zsh_path"
    echo -e "${GREEN}zsh set as default shell. You'll need to log out and back in for this to take effect.${NC}"
}

# Install oh-my-zsh
install_oh_my_zsh() {
    local omz_dir="$HOME/.oh-my-zsh"
    local omz_script="$omz_dir/oh-my-zsh.sh"

    # Check if oh-my-zsh is already properly installed (directory exists AND main script exists)
    if [[ -d "$omz_dir" ]] && [[ -f "$omz_script" ]]; then
        echo -e "${GREEN}oh-my-zsh is already installed.${NC}"
        return 0
    fi

    # If directory exists but main script doesn't, remove the broken installation
    if [[ -d "$omz_dir" ]] && [[ ! -f "$omz_script" ]]; then
        echo -e "${YELLOW}Found incomplete oh-my-zsh installation. Removing and reinstalling...${NC}"
        rm -rf "$omz_dir"
    fi

    echo -e "${BLUE}Installing oh-my-zsh...${NC}"

    # Use unattended install to avoid prompts
    if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended; then
        echo -e "${RED}ERROR: oh-my-zsh installation command failed!${NC}"
        return 1
    fi

    # Verify the installation succeeded by checking for the main script
    if [[ ! -f "$omz_script" ]]; then
        echo -e "${RED}ERROR: oh-my-zsh installation failed - $omz_script not found!${NC}"
        echo -e "${RED}Please check your internet connection and try again.${NC}"
        return 1
    fi

    echo -e "${GREEN}oh-my-zsh installed successfully!${NC}"
    return 0
}

# Install powerlevel10k theme
install_powerlevel10k() {
    # Verify oh-my-zsh is installed before proceeding
    if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
        echo -e "${RED}ERROR: oh-my-zsh is not installed. Cannot install powerlevel10k theme.${NC}"
        return 1
    fi

    local p10k_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k"

    if [[ -d "$p10k_dir" ]]; then
        echo -e "${GREEN}powerlevel10k is already installed.${NC}"
        return 0
    fi

    echo -e "${BLUE}Installing powerlevel10k theme...${NC}"
    if ! git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$p10k_dir"; then
        echo -e "${RED}ERROR: Failed to clone powerlevel10k repository.${NC}"
        return 1
    fi
    echo -e "${GREEN}powerlevel10k installed successfully!${NC}"
}

# Install common CLI tools (eza, bat)
install_cli_tools() {
    echo -e "${BLUE}Installing common CLI tools (eza, bat)...${NC}"

    if [[ "$OS" == "macOS" ]]; then
        # macOS: use Homebrew
        if ! command_exists eza; then
            echo -e "${BLUE}Installing eza via Homebrew...${NC}"
            brew install eza
        else
            echo -e "${GREEN}eza is already installed.${NC}"
        fi

        if ! command_exists bat; then
            echo -e "${BLUE}Installing bat via Homebrew...${NC}"
            brew install bat
        else
            echo -e "${GREEN}bat is already installed.${NC}"
        fi

    elif [[ "$OS" == "Linux" ]]; then
        # Linux: try apt first, fall back to cargo if needed
        sudo apt-get update

        # Install eza (the maintained fork of exa)
        if ! command_exists eza; then
            # Check if eza is available in apt
            if apt-cache show eza &>/dev/null; then
                echo -e "${BLUE}Installing eza via apt...${NC}"
                sudo apt-get install -y eza
            else
                echo -e "${YELLOW}eza not available in apt. Attempting install via cargo...${NC}"
                if command_exists cargo; then
                    cargo install eza
                else
                    echo -e "${YELLOW}cargo not found. Installing rust toolchain...${NC}"
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                    source "$HOME/.cargo/env"
                    cargo install eza
                fi
            fi
        else
            echo -e "${GREEN}eza is already installed.${NC}"
        fi

        # Install bat
        if ! command_exists bat && ! command_exists batcat; then
            if apt-cache show bat &>/dev/null; then
                echo -e "${BLUE}Installing bat via apt...${NC}"
                sudo apt-get install -y bat
            else
                echo -e "${YELLOW}bat not available in apt. Attempting install via cargo...${NC}"
                if command_exists cargo; then
                    cargo install bat
                else
                    echo -e "${YELLOW}cargo not found. Installing rust toolchain...${NC}"
                    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
                    source "$HOME/.cargo/env"
                    cargo install bat
                fi
            fi
        else
            echo -e "${GREEN}bat is already installed.${NC}"
        fi
    fi

    echo -e "${GREEN}CLI tools installation complete!${NC}"
}

# Install zsh-syntax-highlighting
install_zsh_syntax_highlighting() {
    # Check if installed via package manager
    if [[ "$OS" == "macOS" ]]; then
        if brew list zsh-syntax-highlighting &>/dev/null; then
            echo -e "${GREEN}zsh-syntax-highlighting is already installed via Homebrew.${NC}"
            return 0
        fi
        echo -e "${BLUE}Installing zsh-syntax-highlighting via Homebrew...${NC}"
        brew install zsh-syntax-highlighting
    elif [[ "$OS" == "Linux" ]]; then
        # Verify oh-my-zsh is installed before proceeding (needed for plugin directory)
        if [[ ! -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]]; then
            echo -e "${RED}ERROR: oh-my-zsh is not installed. Cannot install zsh-syntax-highlighting as plugin.${NC}"
            return 1
        fi

        local zsh_highlight_dir="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting"
        if [[ -d "$zsh_highlight_dir" ]]; then
            echo -e "${GREEN}zsh-syntax-highlighting is already installed.${NC}"
            return 0
        fi
        echo -e "${BLUE}Installing zsh-syntax-highlighting as oh-my-zsh plugin...${NC}"
        if ! git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$zsh_highlight_dir"; then
            echo -e "${RED}ERROR: Failed to clone zsh-syntax-highlighting repository.${NC}"
            return 1
        fi
    fi
    echo -e "${GREEN}zsh-syntax-highlighting installed successfully!${NC}"
}

# Install all dependencies
install_dependencies() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}     Installing Dependencies           ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    if [[ "$OS" == "macOS" ]]; then
        if ! install_homebrew; then
            return 1
        fi
    fi

    if [[ "$OS" == "Linux" ]]; then
        install_git_curl
    fi

    install_zsh
    set_default_shell

    # Install oh-my-zsh and verify it succeeded before continuing
    if ! install_oh_my_zsh; then
        echo -e "${RED}ERROR: oh-my-zsh installation failed. Cannot continue with theme and plugin installation.${NC}"
        return 1
    fi

    # Only install powerlevel10k after oh-my-zsh is confirmed installed
    install_powerlevel10k
    install_zsh_syntax_highlighting
    install_cli_tools

    echo ""
    echo -e "${GREEN}All dependencies installed successfully!${NC}"
    echo ""
}

# Main setup
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}       Dotfiles Setup Script           ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    detect_os
    echo ""

    if [[ "$OS" == "Unknown" ]]; then
        echo -e "${RED}Unsupported operating system. Exiting.${NC}"
        exit 1
    fi

    # Ask about installing dependencies
    echo -e "${YELLOW}Would you like to install dependencies (zsh, oh-my-zsh, powerlevel10k, zsh-syntax-highlighting)?${NC}"
    read -p "Install dependencies? (y/n): " install_deps
    echo ""

    if [[ "$install_deps" =~ ^[Yy]$ ]]; then
        install_dependencies
    else
        echo -e "${YELLOW}Skipping dependency installation.${NC}"
    fi
    echo ""

    echo -e "${BLUE}Dotfiles directory: ${DOTFILES_DIR}${NC}"
    echo ""

    # Ensure ~/.claude directory exists
    echo -e "${BLUE}Ensuring ~/.claude directory exists...${NC}"
    mkdir -p "$HOME/.claude"
    echo ""

    # Create symlinks for shell config
    echo -e "${BLUE}Setting up shell configuration...${NC}"
    create_symlink "${DOTFILES_DIR}/zshrc" "$HOME/.zshrc"
    echo ""

    # Create symlinks for Claude configs
    echo -e "${BLUE}Setting up Claude configuration...${NC}"
    create_symlink "${DOTFILES_DIR}/claude/CLAUDE.md" "$HOME/.claude/CLAUDE.md"
    create_symlink "${DOTFILES_DIR}/claude/settings.json" "$HOME/.claude/settings.json"
    create_symlink "${DOTFILES_DIR}/claude/settings.local.json" "$HOME/.claude/settings.local.json"
    create_symlink "${DOTFILES_DIR}/claude/statusline-command.sh" "$HOME/.claude/statusline-command.sh"
    echo ""

    # Make statusline-command.sh executable
    echo -e "${BLUE}Making statusline-command.sh executable...${NC}"
    chmod +x "${DOTFILES_DIR}/claude/statusline-command.sh"
    echo -e "${GREEN}Done!${NC}"
    echo ""

    echo -e "${BLUE}========================================${NC}"
    echo -e "${GREEN}Setup complete!${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""
    echo -e "${YELLOW}IMPORTANT: Please restart your shell or run 'zsh' to apply changes.${NC}"
    echo ""
    echo -e "${YELLOW}If you have sensitive credentials (API keys, tokens), add them to a separate file like ~/.zshrc.local and source it from ~/.zshrc${NC}"
}

main "$@"
