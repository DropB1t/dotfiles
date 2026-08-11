# Directory navigation: keep a useful directory stack without duplicates.
setopt AUTO_CD
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS
setopt PUSHD_SILENT

# Globbing: include dotfiles and enable Zsh's extended pattern syntax.
setopt EXTENDED_GLOB
setopt GLOB_DOTS

# Interactive behavior: allow comments and expand variables in the prompt.
setopt INTERACTIVE_COMMENTS
setopt PROMPT_SUBST
unsetopt AUTO_MENU
unsetopt BEEP
