#!/usr/bin/env bash

# Note: Make sure to run this script with appropriate permissions.

# Check if the OS is Ubuntu
if [[ "$(uname -a)" == *"Ubuntu"* ]]; then
	# Check if apt is installed
	if ! command -v apt &> /dev/null; then
		echo "apt package manager is not installed."
		exit 1
	fi

	# Install required packages
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch
    sudo apt update
	packages=("alacritty" "exa" "bat" "fastfetch" "fzf" "ripgrep" "zsh" "curl" "wget" "git" "unzip" "zip" "htop" "btop")

	for package in "${packages[@]}"; do
		if ! dpkg -s "$package" &> /dev/null; then
			echo "Installing $package..."
			sudo apt install -y "$package"
		else
			echo "$package is already installed."
		fi
	done

    # Install zsh4humans
    if command -v curl >/dev/null 2>&1; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
    else
        sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
    fi



	# This script is used to configure the keybindings for switching to applications in GNOME Shell.
	# It uses the 'gsettings' command to set the keybindings for the 'switch-to-application-X' keys, where X is a number from 1 to 9.
	# The keybindings are set to an empty array '[]', effectively disabling the default keybindings.
	for i in $(seq 1 9); do gsettings set org.gnome.shell.keybindings switch-to-application-"${i}" '[]'; done

	# Sets the GNOME Shell window switcher to switch between windows across all workspaces.
	# This command modifies the 'current-workspace-only' property of the 'org.gnome.shell.window-switcher' schema.
	# When set to 'false', the window switcher will show windows from all workspaces.
	# 
	# Usage: gsettings set org.gnome.shell.window-switcher current-workspace-only false
	#
	gsettings set org.gnome.shell.window-switcher current-workspace-only false

else
	echo "At the moment this script is only compatible with Ubuntu distribution."
	exit 1
fi

