# General use.
if (( $+commands[eza] )); then
  alias ls='eza --icons=auto'
  alias l='eza -lh --icons=auto'
  alias ll='eza -alhb --git --icons=auto'
  alias la='eza -albhHigUm --time-style=long-iso --git --color-scale all'
  alias lt='eza --tree --git --icons=auto --color-scale all'
else
  if [[ $OSTYPE == darwin* ]]; then
    alias ls='ls -G'
  else
    alias ls='ls --color=auto'
  fi
  alias l='ls -lh'
  alias ll='ls -alh'
  alias la='ls -A'
  alias lt='find . -print'
fi

if (( ! $+commands[bat] && $+commands[batcat] )); then
  alias bat='batcat'
fi

alias clock='rsclock -S -c'
alias weather='curl https://wttr.in/Pisa'
alias ipinfo='curl --silent https://ipinfo.io | jq'
alias cmkd='cmake -DCMAKE_BUILD_TYPE=Debug'
alias cmkr='cmake -DCMAKE_BUILD_TYPE=Release'
alias ff='fastfetch'
alias lg='lazygit'
alias bt='btop'

alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias ig='grep -i'
alias hig='history | grep -i'

alias mv='mv -i'
alias h='history'
alias q='exit'
alias cl='clear'
alias skp='sudo kill -9'
alias apt-update='sudo apt update && sudo apt upgrade'
alias df='df -h'
alias free='free -m'
alias psmem='ps auxf | sort -nr -k 4 | head -5'
alias pscpu='ps auxf | sort -nr -k 3 | head -5'

alias dotc='cd "$HOME/dotfiles" && code .'
alias cmus='cd "$HOME/Music" && cmus'
alias gs='git status --short --branch'
alias gd='git diff'
