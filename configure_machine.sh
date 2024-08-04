#!/usr/bin/env bash

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

else
	echo "At the moment this script is only compatible with Ubuntu distribution."
	exit 1
fi

