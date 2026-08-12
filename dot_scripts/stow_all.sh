#!/usr/bin/env zsh

setopt null_glob

script_dir="$(cd -- "$(dirname -- "$0")" && pwd)"
repo_dir="$(cd -- "$script_dir/.." && pwd)"

cd -- "$repo_dir"
for d in *(/); do
	[[ "$d" == dot_scripts ]] && continue
	stow -v --no-folding -t ~/ -S "$d"
done
