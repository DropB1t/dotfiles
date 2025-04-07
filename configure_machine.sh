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
	packages=("exa" "bat" "fastfetch" "fzf" "ripgrep" "zsh" "curl" "wget" "git" "unzip" "zip" "htop")
	
	# Check if there is a graphical interface and we are not in a wsl2 environment
	if [[ "$DISPLAY" != "" && "$WSL_DISTRO_NAME" == "" ]]; then
		# Additional gui packages useful for DE installation
		packages+=("alacritty" "gnome-tweaks", "gnome-shell-extension-manager", "gnome-shell-pomodoro", "gir1.2-gtop-2.0" "lm-sensors")
		install_papirus_folders_icon_catppuccin_theme

		# This script is used to configure the keybindings for switching to applications in GNOME Shell.
		# It uses the 'gsettings' command to set the keybindings for the 'switch-to-application-X' keys, where X is a number from 1 to 9.
		# The keybindings are set to an empty array '[]', effectively disabling the default keybindings.
		for i in $(seq 1 9); do gsettings set org.gnome.shell.keybindings switch-to-application-"${i}" '[]'; done

		# Sets the GNOME Shell window switcher to switch between windows across all workspaces.
		# This command modifies the 'current-workspace-only' property of the 'org.gnome.shell.window-switcher' schema.
		# When set to 'false', the window switcher will show windows from all workspaces.
		gsettings set org.gnome.shell.window-switcher current-workspace-only false
	fi
	install_required_packages
	
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

# Function to install required packages
install_required_packages() {
	# Check if the package is already installed
	for package in "${packages[@]}"; do
		if ! dpkg -s "$package" &> /dev/null; then
			echo "Installing $package..."
			sudo apt install -y "$package"
		else
			echo "$package is already installed."
		fi
	done
}

# TODO: Remove catppuccin papirus folders theme and install only plain colors
# Function to install Papirus Folders Icon Catppuccin theme
install_papirus_folders_icon_catppuccin_theme() {
	sudo add-apt-repository ppa:papirus/papirus
	sudo apt update
	sudo apt install -y papirus-icon-theme
	cd /tmp
	git clone https://github.com/catppuccin/papirus-folders.git
	cd papirus-folders
	sudo cp -r src/* /usr/share/icons/Papirus
	curl -LO https://raw.githubusercontent.com/PapirusDevelopmentTeam/papirus-folders/master/papirus-folders && chmod +x ./papirus-folders
	./papirus-folders -C teal --theme Papirus-Dark
	#./papirus-folders -C cat-mocha-lavender --theme Papirus-Dark
	cd -
	rm -rf /tmp/papirus-folders
}
