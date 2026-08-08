#!/usr/bin/env zsh

for d in *(/); do stow -v --no-folding -t ~/ -S "$d"; done
