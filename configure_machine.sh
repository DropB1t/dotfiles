#!/usr/bin/env bash

# Note: Make sure to run this script with appropriate permissions.

install_required_packages() {
	for package in "${packages[@]}"; do
		if ! dpkg -s "$package" &> /dev/null; then
			echo "Installing $package..."
			sudo apt install -y "$package"
		else
			echo "$package is already installed."
		fi
	done
}

# Function to install papirus-folders theme
install_papirus_folders_theme() {
	sudo add-apt-repository ppa:papirus/papirus
	sudo apt update
	sudo apt install -y papirus-icon-theme
	wget -qO- https://git.io/papirus-folders-install | sh

	if ! command -v papirus-folders &> /dev/null; then
		echo "error: papirus-folders is not installed"
		exit 1
	fi

	papirus-folders -C bluegrey --theme Papirus
	cd - || return
}

# Function to install ghostty terminal
install_ghostty() {
	/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh)"

	if ! command -v ghostty &> /dev/null; then
		echo "error: ghostty is not installed"
		exit 1
	fi
}

# Function to install yazi file manager
install_yazi() {
	curl -fsSL https://yazi-rs.github.io/builds/yazi-keyring.gpg | sudo tee /usr/share/keyrings/yazi-keyring.gpg >/dev/null
	echo 'deb [signed-by=/usr/share/keyrings/yazi-keyring.gpg] https://yazi-rs.github.io/builds/ stable main' | sudo tee /etc/apt/sources.list.d/yazi.list >/dev/null
	sudo apt update && sudo apt install -y yazi

	if ! command -v yazi &> /dev/null; then
		echo "error: yazi is not installed"
		exit 1
	fi
}

if [[ "$(uname -a)" == *"Ubuntu"* || "$(uname -a)" == *"Debian"* || "$(uname -a)" == *"WSL"* ]]; then
	if ! command -v apt &> /dev/null; then
		echo "apt package manager is not installed."
		exit 1
	fi

	# Install required packages
	sudo apt install software-properties-common -y
    sudo add-apt-repository ppa:zhangsongcui3371/fastfetch -y
    sudo apt update -y
	packages=("stow" "build-essential" "gcc" "nano" "vim" "eza" "bat" "fastfetch" "fzf" "jq" "ripgrep" "zsh" "curl" "wget" "git" "unzip" "zip" "htop")

	# Check if there is a graphical interface and we are not in a wsl2 environment
	if [[ "$DISPLAY" != "" && "$WSL_DISTRO_NAME" == "" ]]; then
		# Additional gui packages useful for DE installation
		packages+=("gnome-tweaks" "gnome-shell-extension-manager" "gnome-shell-pomodoro" "gir1.2-gtop-2.0" "lm-sensors")
		install_papirus_folders_theme
		install_ghostty

		# This script is used to configure the keybindings for switching to applications in GNOME Shell.
		# It uses the 'gsettings' command to set the keybindings for the 'switch-to-application-X' keys, where X is a number from 1 to 9.
		# The keybindings are set to an empty array '[]', effectively disabling the default keybindings.
		for i in $(seq 1 9); do gsettings set org.gnome.shell.keybindings switch-to-application-"${i}" '[]'; done

		# Sets the GNOME Shell window switcher to switch between windows across all workspaces.
		# This command modifies the 'current-workspace-only' property of the 'org.gnome.shell.window-switcher' schema.
		# When set to 'false', the window switcher will show windows from all workspaces.
		gsettings set org.gnome.shell.window-switcher current-workspace-only false
	fi
	install_yazi
	install_required_packages

	# Check if batcat is installed then create a symlink to bat
	if command -v batcat &> /dev/null; then
		echo "Creating symlink for batcat to bat..."
		sudo ln -s "$(command -v batcat)" /usr/bin/bat
	else
		echo "batcat is not installed."
	fi

    # Install zsh4humans
    if command -v curl >/dev/null 2>&1; then
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
    else
        sh -c "$(wget -O- https://raw.githubusercontent.com/romkatv/zsh4humans/v5/install)"
    fi

else
	echo "At the moment this script is only compatible with Ubuntu distribution."
	exit 1
fi
