#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
config_dir="$repo_dir/zsh/.config/zsh"
test_root="$(mktemp -d)"
trap 'rm -rf -- "$test_root"' EXIT

printf 'Checking Zsh syntax...\n'
zsh -n \
	"$repo_dir/zsh/.zshenv" \
	"$config_dir/.zshrc" \
	"$config_dir"/*.zsh \
"$repo_dir/zsh/.local/bin/zsh-update"

mkdir -p -- \
	"$test_root/home" \
	"$test_root/config" \
	"$test_root/data/zsh" \
	"$test_root/cache/zsh" \
	"$test_root/minimal-bin"
ln -s -- "$(command -v zsh)" "$test_root/minimal-bin/zsh"
ln -s -- "$(command -v mv)" "$test_root/minimal-bin/mv"

printf 'Checking XDG bootstrap...\n'
env -i HOME="$test_root/home" PATH="$PATH" \
	REPO_ZSHENV="$repo_dir/zsh/.zshenv" zsh -f -c '
	source "$REPO_ZSHENV"
	[[ $XDG_CONFIG_HOME == "$HOME/.config" ]]
	[[ $XDG_DATA_HOME == "$HOME/.local/share" ]]
	[[ $XDG_CACHE_HOME == "$HOME/.cache" ]]
	[[ $ZDOTDIR == "$HOME/.config/zsh" ]]
'

startup_environment=(
	HOME="$test_root/home"
	XDG_CONFIG_HOME="$test_root/config"
	XDG_DATA_HOME="$test_root/data"
	XDG_CACHE_HOME="$test_root/cache"
	ZDOTDIR="$config_dir"
	ZSH_PLUGIN_DIR="$test_root/missing-plugins"
	ZSH_DISABLE_SSH_AGENT=1
	TERM="${TERM:-xterm-256color}"
)

printf 'Checking isolated interactive startup...\n'
env -i "${startup_environment[@]}" PATH="$PATH" zsh -d -i -c '
	[[ $HISTFILE == "$XDG_DATA_HOME/zsh/history" ]]
	[[ -o interactive ]]
'

printf 'Checking startup without optional tools or plugins...\n'
env -i "${startup_environment[@]}" PATH="$test_root/minimal-bin" \
	"$test_root/minimal-bin/zsh" -d -i -c exit

printf 'Measuring isolated interactive startup...\n'
TIMEFORMAT='  startup: %3R seconds'
time env -i "${startup_environment[@]}" PATH="$PATH" zsh -d -i -c exit

printf 'Zsh validation passed.\n'
