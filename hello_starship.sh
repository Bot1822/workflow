#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_CONFIG_FILE="$SCRIPT_DIR/starship/starship.toml"
TARGET_CONFIG_DIR="$HOME/.config"
TARGET_CONFIG_FILE="$TARGET_CONFIG_DIR/starship.toml"

resolve_starship_bin() {
    if command -v starship >/dev/null 2>&1; then
        command -v starship
        return 0
    fi

    if [ -x "$HOME/.local/bin/starship" ]; then
        echo "$HOME/.local/bin/starship"
        return 0
    fi

    return 1
}

install_starship() {
    if resolve_starship_bin >/dev/null 2>&1; then
        echo "starship is already installed."
        return
    fi

    if command -v brew >/dev/null 2>&1; then
        echo "Installing starship with Homebrew..."
        brew install starship
        return
    fi

    if command -v cargo >/dev/null 2>&1; then
        echo "Installing starship with cargo..."
        cargo install starship --locked
        return
    fi

    if command -v curl >/dev/null 2>&1; then
        echo "Installing starship with the official installer..."
        curl -sS https://starship.rs/install.sh | sh
        return
    fi

    echo "Unable to install starship automatically." >&2
    echo "Install Homebrew, Rust cargo, or curl and rerun this script." >&2
    exit 1
}

sync_config() {
    if [ ! -f "$REPO_CONFIG_FILE" ]; then
        echo "Missing repository config: $REPO_CONFIG_FILE" >&2
        exit 1
    fi

    mkdir -p "$TARGET_CONFIG_DIR"

    if [ -f "$TARGET_CONFIG_FILE" ] && ! cmp -s "$REPO_CONFIG_FILE" "$TARGET_CONFIG_FILE"; then
        local backup_path
        backup_path="${TARGET_CONFIG_FILE}.backup.$(date +%Y%m%d%H%M%S)"
        echo "Backing up existing starship config to $backup_path"
        cp "$TARGET_CONFIG_FILE" "$backup_path"
    fi

    cp "$REPO_CONFIG_FILE" "$TARGET_CONFIG_FILE"
    echo "Copied starship config into $TARGET_CONFIG_FILE"
}

append_block_if_missing() {
    local file="$1"
    local marker="$2"
    local block="$3"

    mkdir -p "$(dirname "$file")"
    touch "$file"

    if grep -Fq "$marker" "$file"; then
        echo "starship is already configured in $file"
        return
    fi

    printf "\n%s\n" "$block" >> "$file"
    echo "Configured starship in $file"
}

configure_zsh() {
    local file="$HOME/.zshrc"
    local marker='starship init zsh'
    local block
    block="$(cat <<'EOF'
# >>> starship initialize >>>
if [ -x "$HOME/.local/bin/starship" ]; then
  eval "$("$HOME/.local/bin/starship" init zsh)"
elif command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi
# <<< starship initialize <<<
EOF
)"

    append_block_if_missing "$file" "$marker" "$block"
}

configure_bash() {
    local file="$HOME/.bashrc"
    local marker='starship init bash'
    local block
    block="$(cat <<'EOF'
# >>> starship initialize >>>
if [ -x "$HOME/.local/bin/starship" ]; then
  eval "$("$HOME/.local/bin/starship" init bash)"
elif command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi
# <<< starship initialize <<<
EOF
)"

    append_block_if_missing "$file" "$marker" "$block"
}

configure_fish() {
    local file="$HOME/.config/fish/config.fish"
    local marker='starship init fish'
    local block
    block="$(cat <<'EOF'
# >>> starship initialize >>>
if test -x "$HOME/.local/bin/starship"
    "$HOME/.local/bin/starship" init fish | source
else if type -q starship
    starship init fish | source
end
# <<< starship initialize <<<
EOF
)"

    append_block_if_missing "$file" "$marker" "$block"
}

add_shell_once() {
    local candidate="$1"
    local existing

    for existing in "${TARGET_SHELLS[@]}"; do
        if [ "$existing" = "$candidate" ]; then
            return
        fi
    done

    TARGET_SHELLS+=("$candidate")
}

resolve_requested_shells() {
    local requested_shell
    TARGET_SHELLS=()

    if [ "$#" -eq 0 ]; then
        requested_shell="$(basename "${SHELL:-zsh}")"
        case "$requested_shell" in
            bash|zsh|fish)
                add_shell_once "$requested_shell"
                ;;
            *)
                add_shell_once "zsh"
                ;;
        esac
        return
    fi

    for requested_shell in "$@"; do
        case "$requested_shell" in
            all)
                add_shell_once "bash"
                add_shell_once "zsh"
                add_shell_once "fish"
                ;;
            bash|zsh|fish)
                add_shell_once "$requested_shell"
                ;;
            *)
                echo "Unsupported shell: $requested_shell" >&2
                echo "Use one or more of: bash, zsh, fish, all" >&2
                exit 1
                ;;
        esac
    done
}

configure_shells() {
    local shell_name

    for shell_name in "${TARGET_SHELLS[@]}"; do
        case "$shell_name" in
            bash)
                configure_bash
                ;;
            zsh)
                configure_zsh
                ;;
            fish)
                configure_fish
                ;;
        esac
    done
}

main() {
    resolve_requested_shells "$@"
    install_starship
    sync_config
    configure_shells

    echo
    echo "starship setup complete."
    echo "Configured shells: ${TARGET_SHELLS[*]}"
    if resolve_starship_bin >/dev/null 2>&1; then
        "$(resolve_starship_bin)" --version
    fi
}

main "$@"
