#!/bin/bash

# Global variables
PACKAGE_MANAGER=""

# Function to check package manager
check_package_manager() {
    if command -v apt &> /dev/null
    then
        PACKAGE_MANAGER="apt"
    elif command -v brew &> /dev/null
    then
        PACKAGE_MANAGER="brew"
    elif command -v pacman &> /dev/null
    then
        PACKAGE_MANAGER="pacman"
    elif command -v dnf &> /dev/null
    then
        PACKAGE_MANAGER="dnf"
    elif command -v yum &> /dev/null
    then
        PACKAGE_MANAGER="yum"
    else
        echo "No package manager found. Please install a package manager (apt, brew, pacman, dnf, yum) and try again."
        exit 1
    fi
}

# Function to check if zsh is installed
check_install_zsh() {
    if ! command -v zsh &> /dev/null
    then
        echo "zsh is not installed. Installing zsh..."
        case $PACKAGE_MANAGER in
            apt)
                sudo apt install zsh -y
                ;;
            brew)
                brew install zsh
                ;;
            pacman)
                sudo pacman -S zsh --noconfirm
                ;;
            dnf)
                sudo dnf install zsh -y
                ;;
            yum)
                sudo yum install zsh -y
                ;;
        esac
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
        echo "cd \$WORKSPACE" >> ~/.zshrc
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