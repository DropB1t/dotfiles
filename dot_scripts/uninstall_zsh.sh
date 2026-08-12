#!/usr/bin/env bash

set -euo pipefail

repo_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

if ! command -v stow >/dev/null 2>&1; then
	printf 'error: GNU Stow is required to uninstall this package\n' >&2
	exit 1
fi

printf 'Checking Stow removal...\n'
(
	cd -- "$repo_dir"
	stow -n -v --no-folding -t "$HOME" -D zsh
	stow -v --no-folding -t "$HOME" -D zsh
)

printf 'Zsh configuration links removed.\n'
printf 'History and plugin data were preserved under %s/zsh.\n' \
	"${XDG_DATA_HOME:-$HOME/.local/share}"
