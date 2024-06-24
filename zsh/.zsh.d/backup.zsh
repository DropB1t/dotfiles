
export NVM_COMPLETION=true
export NVM_LAZY_LOAD=true

bindkey -e

ZSH_AUTOSUGGEST_MANUAL_REBIND=1

[ -s "/home/dropbit/.bun/_bun" ] && source "/home/dropbit/.bun/_bun"

export WALK_EDITOR=code 

source "$HOME/.config/zsh/zsh-nvm/zsh-nvm.plugin.zsh"
source "$HOME/.config/zsh/catppuccin-syntax-highlighting.zsh"
source "$HOME/.config/zsh/exports.zsh"
source "$HOME/.config/zsh/history.zsh"
source "$HOME/.config/zsh/aliases.zsh"

eval "$(dircolors -b)"

for key ('^[[A' '^P' ${terminfo[kcuu1]}) bindkey ${key} history-substring-search-up
for key ('^[[B' '^N' ${terminfo[kcud1]}) bindkey ${key} history-substring-search-down
for key ('k') bindkey -M vicmd ${key} history-substring-search-up
for key ('j') bindkey -M vicmd ${key} history-substring-search-down
unset key


#env
. "$HOME/.cargo/env"
