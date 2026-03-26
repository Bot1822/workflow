#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG_DIR="$SCRIPT_DIR/yazi"
TARGET_CONFIG_DIR="$HOME/.config/yazi"

install_yazi() {
    if command -v yazi &> /dev/null && command -v ya &> /dev/null; then
        echo "yazi is already installed."
        return
    fi

    if command -v brew &> /dev/null; then
        echo "Installing yazi with Homebrew..."
        brew install yazi
        return
    fi

    if command -v cargo &> /dev/null; then
        echo "Installing yazi with cargo..."
        cargo install --locked yazi-fm yazi-cli
        return
    fi

    echo "Unable to install yazi without sudo."
    echo "Install Homebrew or Rust cargo in your user environment and rerun this script."
    exit 1
}

sync_config() {
    mkdir -p "$HOME/.config"

    if [ -L "$TARGET_CONFIG_DIR" ]; then
        CURRENT_TARGET="$(readlink "$TARGET_CONFIG_DIR")"
        echo "Replacing symlinked yazi config ($CURRENT_TARGET) with a writable local copy."
        rm "$TARGET_CONFIG_DIR"
    elif [ -f "$TARGET_CONFIG_DIR" ]; then
        BACKUP_PATH="${TARGET_CONFIG_DIR}.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backing up existing yazi config file to $BACKUP_PATH"
        mv "$TARGET_CONFIG_DIR" "$BACKUP_PATH"
    fi

    mkdir -p "$TARGET_CONFIG_DIR"
    cp -R "$REPO_CONFIG_DIR/." "$TARGET_CONFIG_DIR/"
    echo "Copied yazi config into $TARGET_CONFIG_DIR"
}

sync_packages() {
    if ! command -v ya &> /dev/null; then
        echo "ya is not available after installation."
        exit 1
    fi

    if ya pkg install; then
        echo "yazi plugins and flavors synced."
        return
    fi

    echo "Failed to sync yazi plugins and flavors from package.toml."
    exit 1
}

main() {
    install_yazi
    sync_config
    sync_packages
    yazi --version
}

main "$@"
