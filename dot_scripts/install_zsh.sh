#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
plugin_dir="$data_home/zsh/plugins"
history_file="$data_home/zsh/history"
install_plugins=true

if [[ ${1:-} == "--no-plugins" ]]; then
	install_plugins=false
elif [[ $# -gt 0 ]]; then
	printf 'usage: %s [--no-plugins]\n' "$0" >&2
	exit 2
fi

missing=()
for command_name in zsh git stow; do
	command -v "$command_name" >/dev/null 2>&1 || missing+=("$command_name")
done

if (( ${#missing[@]} )); then
	printf 'error: missing required commands: %s\n' "${missing[*]}" >&2
	exit 1
fi

if ! command -v fzf >/dev/null 2>&1; then
	printf 'warning: fzf is not installed; fuzzy widgets will remain disabled\n' >&2
fi

if [[ "$config_home" != "$HOME/.config" ]]; then
	printf 'error: the zsh Stow package mirrors %s; XDG_CONFIG_HOME is %s\n' \
		"$HOME/.config" "$config_home" >&2
	exit 1
fi

mkdir -p -- \
	"$config_home" \
	"$data_home/zsh" \
	"$cache_home/zsh" \
	"$HOME/.local/bin"

if [[ -f "$HOME/.zhistory" && ! -e "$history_file" ]]; then
	printf 'Migrating existing history to %s...\n' "$history_file"
	cp -p "$HOME/.zhistory" "$history_file"
fi

install_plugin() {
	local name=$1
	local url=$2
	local ref=$3
	local expected_commit=$4
	local destination="$plugin_dir/$name"
	local fetched_commit
	local -i new_checkout=0

	if [[ -e "$destination" && ! -d "$destination/.git" ]]; then
		printf 'error: %s exists and is not a Git checkout\n' "$destination" >&2
		return 1
	fi

	if [[ -d "$destination/.git" ]]; then
		if [[ -n "$(git -C "$destination" status --porcelain)" ]]; then
			printf 'error: refusing to overwrite local changes in %s\n' "$destination" >&2
			return 1
		fi
		printf 'Updating %s to %s...\n' "$name" "$ref"
		git -C "$destination" remote set-url origin "$url"
	else
		printf 'Installing %s at %s...\n' "$name" "$ref"
		mkdir -p -- "$destination"
		git -C "$destination" init --quiet
		git -C "$destination" remote add origin "$url"
		new_checkout=1
	fi

	if ! git -C "$destination" fetch --quiet --depth 1 origin "$ref"; then
		(( new_checkout )) && rm -rf -- "$destination"
		return 1
	fi

	fetched_commit="$(git -C "$destination" rev-parse 'FETCH_HEAD^{commit}')"
	if [[ "$fetched_commit" != "$expected_commit" ]]; then
		printf 'error: %s resolved to unexpected commit %s\n' \
			"$ref" "$fetched_commit" >&2
		(( new_checkout )) && rm -rf -- "$destination"
		return 1
	fi

	git -C "$destination" checkout --quiet --detach "$expected_commit"
}

if $install_plugins; then
	mkdir -p -- "$plugin_dir"
	install_plugin zsh-autosuggestions \
		https://github.com/zsh-users/zsh-autosuggestions.git v0.7.1 \
		e52ee8ca55bcc56a17c828767a3f98f22a68d4eb
	install_plugin zsh-syntax-highlighting \
		https://github.com/zsh-users/zsh-syntax-highlighting.git 0.8.0 \
		db085e4661f6aafd24e5acb5b2e17e4dd5dddf3e
fi

printf 'Checking Stow operations...\n'
(
	cd -- "$repo_dir"
	stow -n -v --no-folding -t "$HOME" -R zsh
	stow -v --no-folding -t "$HOME" -R zsh
)

"$repo_dir/dot_scripts/test_zsh.sh"

printf '\nInstalled native Zsh configuration:\n'
printf '  config:  %s\n' "$config_home/zsh"
printf '  plugins: %s\n' "$plugin_dir"
printf '  history: %s\n' "$history_file"
printf 'Restart Zsh to use the new configuration.\n'
