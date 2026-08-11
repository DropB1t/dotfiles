#!/usr/bin/env bash

# Note: Make sure to run this script with appropriate permissions.

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

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

# Function to install delta from the latest GitHub release
install_delta() {
	if command -v delta &> /dev/null; then
		echo "delta is already installed."
		return
	fi

	local version
	version="$(wget -qO- https://api.github.com/repos/dandavison/delta/releases/latest | jq -r '.tag_name')"

	if [[ -z "$version" || "$version" == "null" ]] || ! wget -q "https://github.com/dandavison/delta/releases/download/$version/git-delta_${version}_amd64.deb" -O /tmp/git-delta.deb; then
		echo "error: failed to download delta"
		exit 1
	fi

	sudo dpkg -i /tmp/git-delta.deb
	rm -f /tmp/git-delta.deb

	if ! command -v delta &> /dev/null; then
		echo "error: delta is not installed"
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
	packages=("stow" "build-essential" "gcc" "nano" "less" "vim" "eza" "bat" "fastfetch" "fzf" "jq" "ripgrep" "zsh" "curl" "wget" "git" "dpkg" "unzip" "zip" "htop")

	install_required_packages

	# Check if there is a graphical interface and we are not in a wsl2 environment
	if [[ "$DISPLAY" != "" && "$WSL_DISTRO_NAME" == "" ]]; then
		# Additional gui packages useful for DE installation
		packages+=("gnome-tweaks" "gnome-shell-extension-manager" "lm-sensors")
		install_papirus_folders_theme
		install_ghostty
		install_yazi
		install_delta

		# This script is used to configure the keybindings for switching to applications in GNOME Shell.
		# It uses the 'gsettings' command to set the keybindings for the 'switch-to-application-X' keys, where X is a number from 1 to 9.
		# The keybindings are set to an empty array '[]', effectively disabling the default keybindings.
		for i in $(seq 1 9); do gsettings set org.gnome.shell.keybindings switch-to-application-"${i}" '[]'; done

		# Sets the GNOME Shell window switcher to switch between windows across all workspaces.
		# This command modifies the 'current-workspace-only' property of the 'org.gnome.shell.window-switcher' schema.
		# When set to 'false', the window switcher will show windows from all workspaces.
		gsettings set org.gnome.shell.window-switcher current-workspace-only false
	fi

	# Check if batcat is installed then create a symlink to bat
	if command -v batcat &> /dev/null; then
		echo "Creating symlink for batcat to bat..."
		sudo ln -s "$(command -v batcat)" /usr/bin/bat
	else
		echo "batcat is not installed."
	fi

	# Install the native Zsh configuration and its pinned plugins.
	"$script_dir/install"

else
	echo "At the moment this script is only compatible with Ubuntu distribution."
	exit 1
fi
