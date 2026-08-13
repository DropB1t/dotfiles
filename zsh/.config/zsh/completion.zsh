autoload -Uz compinit
zmodload zsh/complist

bindkey -M menuselect '^[[Z' reverse-menu-complete  # Shift-Tab: move backwards through the completion menu.

typeset _completion_cache_dir="$XDG_CACHE_HOME/zsh"
typeset _completion_dump="$_completion_cache_dir/zcompdump-$ZSH_VERSION"
[[ -d "$_completion_cache_dir" ]] || mkdir -p -- "$_completion_cache_dir"

zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes
zstyle ':completion:*' list-grouped yes
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*' special-dirs true
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path "$_completion_cache_dir"

if [[ -n ${LS_COLORS:-} ]]; then
  zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
fi

if [[ -s "$_completion_dump" && "$_completion_dump" -nt "$ZDOTDIR/completion.zsh" ]]; then
  compinit -C -d "$_completion_dump"
else
  compinit -d "$_completion_dump"
fi

unset _completion_cache_dir _completion_dump
