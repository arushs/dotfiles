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

# Main setup
main() {
    echo -e "${BLUE}========================================${NC}"
    echo -e "${BLUE}       Dotfiles Setup Script           ${NC}"
    echo -e "${BLUE}========================================${NC}"
    echo ""

    detect_os
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
    echo -e "${YELLOW}Note: You may need to restart your shell or run 'source ~/.zshrc' for changes to take effect.${NC}"
    echo ""
    echo -e "${YELLOW}If you have sensitive credentials (API keys, tokens), add them to a separate file like ~/.zshrc.local and source it from ~/.zshrc${NC}"
}

main "$@"
