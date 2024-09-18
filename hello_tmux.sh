#!bin/bash

# print all commands
set -x

# Global variables
TMUX_CONFIG_FILE=~/.tmux.conf

# Set package manager
source get_package_manager.sh

# Function to check if tmux is installed
check_install_tmux() {
    if ! command -v tmux &> /dev/null
    then
        echo "tmux is not installed. Installing tmux..."
        $PACKAGE_MANAGER install tmux
    else
        echo "tmux is already installed."
    fi
}

# Set default shell
set_default_shell() {
    # check if tmux config file exists
    if [ ! -f "$TMUX_CONFIG_FILE" ]; then
        echo "$TMUX_CONFIG_FILE does not exist. Creating $TMUX_CONFIG_FILE..."
        touch "$TMUX_CONFIG_FILE"
    fi

    # find all available shells
    echo "Available shells:"
    cat /etc/shells

    # ask user to select a shell
    echo "Please select a shell from the list above: "
    read -r SHELL

    # check if selected shell is available
    if ! command -v "$SHELL" &> /dev/null
    then
        echo "$SHELL is not available. Please select a valid shell."
        exit 1
    fi

    # set selected shell as default shell
    echo "Setting $SHELL as default shell..."
    SHELL_PATH=$(command -v "$SHELL")
    echo "set -g default-shell $SHELL_PATH" > "$TMUX_CONFIG_FILE"
}

# main function
main() {
    check_install_tmux
    set_default_shell
}

# call main function
main
# Run the script
# bash hello_tmux.sh
