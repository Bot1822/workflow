#!bin/bash
# usage: bash get_package_manager.sh
# usage: source get_package_manager.sh

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

# set package manager
check_package_manager

# Run the script
# bash get_package_manager.sh
# source get_package_manager.sh