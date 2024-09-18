# Introduction

This repository contains scripts to set up your workflow such as configuring your environment, installing and configuring tools, and setting up your project.

# Usage

To use the scripts in this repository, you can either clone the repository or download the scripts directly. You can then run the scripts in your terminal.

`hello_zsh.sh`
This script will:

- Check if zsh is installed and install it if necessary.
- Install oh-my-zsh.
- Configure zsh theme and plugins.
- Set up a workspace environment variable.

To run the script:
```bash
bash hello_zsh.sh
```

`get_package_manager.sh`This script will:

- Detect the package manager available on your system (`apt`, `brew`, `pacman`, `dnf`, `yum`).
To run the script:

```bash
bash get_package_manager.sh
```

or

```bash
source get_package_manager.sh
```

`hello_tmux.sh`
This script will:

- Check if tmux is installed and install it if necessary.
- Set the default shell for tmux.
To run the script:

```bash
bash hello_tmux.sh
```

Notes
- Ensure you have the necessary permissions to install software on your system.
- The scripts are designed to work on both macOS and Linux systems.
- For zsh configuration, the script modifies the .zshrc file in your home directory.
- For tmux configuration, the script creates or modifies the .tmux.conf file in your home directory.