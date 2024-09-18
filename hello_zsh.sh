#!/bin/bash

source get_package_manager.sh

# Function to check if zsh is installed
check_install_zsh() {
    if ! command -v zsh &> /dev/null
    then
        echo "zsh is not installed. Installing zsh..."
        $PACKAGE_MANAGER install zsh -y
    else
        echo "zsh is already installed."
    fi
}

# Function to install oh-my-zsh
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        echo "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
    else
        echo "oh-my-zsh is already installed."
    fi
}

# Function to configure zsh theme and plugins
configure_zsh() {
    ZSHRC="$HOME/.zshrc"
    
    if [ -f "$ZSHRC" ]; then
        if [[ "$OSTYPE" == "darwin"* ]]; then
            # MacOS
            sed -i '' 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' "$ZSHRC"
            sed -i '' 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' "$ZSHRC"
        else
            # Linux
            sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="agnoster"/g' "$ZSHRC"
            sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' "$ZSHRC"
        fi
        
        # Install plugin dependencies
        if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions" ]; then
            git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
        fi
        if [ ! -d "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting" ]; then
            git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
        fi
    else
        echo "$ZSHRC file does not exist. Please ensure oh-my-zsh is installed properly."
        exit 1
    fi
}

# Function to set up workspace environment variable
setup_workspace() {
    # check if WORKSPACE variable is already set
    if grep -q "export WORKSPACE" ~/.zshrc; then
        echo "Workspace is already set up."
        exit 0
    fi
    # Something like ~/Workspace
    read -p "Enter the path to your workspace: " workspace_path
    if [ -d "$workspace_path" ]; then
        echo "export WORKSPACE=$workspace_path" >> ~/.zshrc
        echo "alias cdw='cd \$WORKSPACE'" >> ~/.zshrc
        echo "Workspace setup complete."
    else
        echo "The provided path does not exist. Please make sure to provide a valid directory."
        exit 1
    fi
}

# Main script
check_package_manager
check_install_zsh
install_oh_my_zsh
configure_zsh
setup_workspace

echo "Script execution completed. Please restart your shell."