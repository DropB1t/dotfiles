#!/usr/bin/env zsh

for d in *(/); do stow -v -t ~/ -S "$d"; done
