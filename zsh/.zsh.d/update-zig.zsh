update-zig() {
    # Define the base directory for Zig installation
    local install_dir="/opt/zig"

    # Fetch the Zig releases JSON and parse for the latest stable version tarball URL
    echo "Fetching the latest Zig stable version..."
    local download_data=$(curl -s https://ziglang.org/download/index.json)
    local tarball_url=$(echo "$download_data" | jq -r '
        to_entries
        | map(select(.key != "master"))  # Exclude the master (nightly) version
        | sort_by(.key | split(".") | map(tonumber))  # Sort versions
        | reverse  # Most recent first
        | .[0]  # Get the most recent entry
        | .value."x86_64-linux".tarball  # Extract the tarball URL for Linux
    ')

    # Check if the version is already installed
    local installed_version=$(zig version | head -n 1 | cut -d ' ' -f 2)
    # Extract the latest version from the JSON keys
    local latest_version=$(echo "$download_data" | jq -r '
        to_entries
        | map(select(.key != "master"))  # Exclude the master (nightly) version
        | sort_by(.key | split(".") | map(tonumber))  # Sort versions
        | reverse  # Most recent first
        | .[0]  # Get the most recent entry
        | .key  # Extract the version number
    ')

    echo "Latest version: $latest_version"
    if [[ "$installed_version" == "$latest_version" ]]; then
        echo "Zig is already up-to-date at version $installed_version."
        return 0
    fi
    exit 0


    if [[ -z "$tarball_url" ]]; then
        echo "Failed to fetch the Zig tarball URL. Check your network or the Zig website."
        return 1
    fi

    echo "Downloading Zig from $tarball_url..."

    # Download and prepare for installation
    local temp_dir=$(mktemp -d)
    local zig_archive="$temp_dir/zig.tar.xz"
    curl -L -o "$zig_archive" "$tarball_url"

    if [[ $? -ne 0 ]]; then
        echo "Failed to download Zig."
        rm -rf "$temp_dir"
        return 1
    fi

    # Extract and install
    echo "Installing Zig to $install_dir..."
    sudo rm -rf "$install_dir"  # Clear the old installation if exists
    sudo mkdir -p "$install_dir"
    sudo tar -xvf "$zig_archive" --strip-components=1 -C "$install_dir"

    if [[ $? -ne 0 ]]; then
        echo "Failed to extract and install Zig."
        rm -rf "$temp_dir"
        return 1
    fi

    # Cleanup
    rm -rf "$temp_dir"
    echo "Zig installed successfully to $install_dir."
}
