#!/usr/bin/env bash

for d in *(/); do stow -v -t ~/ -S "$d"; done
