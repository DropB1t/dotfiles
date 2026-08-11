bindkey -e  # Use Emacs-style line editing.
zmodload zsh/parameter
zmodload zsh/terminfo

typeset -g _history_substring_query=''
typeset -g _history_substring_result=''
typeset -gi _history_substring_event=0

_history_substring_prepare() {
  if (( ! _history_substring_event )) || [[ $BUFFER != $_history_substring_result ]]; then
    _history_substring_query=$BUFFER
    _history_substring_result=$BUFFER
    _history_substring_event=$HISTCMD
  fi
}

history-substring-search-up() {
  _history_substring_prepare

  local entry
  local -i event=$(( _history_substring_event - 1 ))
  while (( event > 0 )); do
    entry=${history[$event]}
    if [[ -n $entry && $entry == *"$_history_substring_query"* ]]; then
      BUFFER=$entry
      CURSOR=${#BUFFER}
      _history_substring_result=$entry
      _history_substring_event=$event
      return 0
    fi
    (( --event ))
  done
  return 1
}

history-substring-search-down() {
  _history_substring_prepare

  local entry
  local -i event=$(( _history_substring_event + 1 ))
  while (( event < HISTCMD )); do
    entry=${history[$event]}
    if [[ -n $entry && $entry == *"$_history_substring_query"* ]]; then
      BUFFER=$entry
      CURSOR=${#BUFFER}
      _history_substring_result=$entry
      _history_substring_event=$event
      return 0
    fi
    (( ++event ))
  done

  BUFFER=$_history_substring_query
  CURSOR=${#BUFFER}
  _history_substring_result=$BUFFER
  _history_substring_event=$HISTCMD
}

_native_backward_kill_zword() {
  local WORDCHARS=''
  zle backward-kill-word
}

_native_cd_up() {
  builtin cd .. || return
  zle reset-prompt
}

_native_cd_down() {
  local selected
  local -a directories
  directories=(./*(N/))

  if (( ! ${#directories} )); then
    zle -M 'no child directories'
    return 0
  elif (( ${#directories} == 1 )); then
    selected=$directories[1]
  elif (( $+commands[fzf] )); then
    selected=$(print -rl -- "${directories[@]}" |
      fzf --height=40% --layout=reverse --border \
        --prompt='Directory> ') || return 0
  else
    zle -M 'multiple child directories; install fzf to choose one'
    return 0
  fi

  builtin cd -- "$selected" || return
  zle reset-prompt
}

_minimal_fzf_history() {
  (( $+commands[fzf] )) || {
    zle -M 'fzf is not installed'
    return 0
  }

  local selected
  selected=$(fc -rl 1 | fzf \
    --height=40% --layout=reverse --border \
    --query="$LBUFFER") || return 0

  selected=${selected##[[:space:]]#<->[[:space:]]#}
  BUFFER=$selected
  CURSOR=${#BUFFER}
}

_minimal_fzf_files() {
  (( $+commands[fzf] )) || {
    zle -M 'fzf is not installed'
    return 0
  }

  local selected
  local -a file_command

  if (( $+commands[fd] )); then
    file_command=(fd --type f --hidden --follow --exclude .git)
  elif (( $+commands[fdfind] )); then
    file_command=(fdfind --type f --hidden --follow --exclude .git)
  else
    file_command=(find . -type f -not -path '*/.git/*')
  fi

  selected=$("${file_command[@]}" 2>/dev/null | fzf \
    --height=40% --layout=reverse --border) || return 0

  LBUFFER+="${(q)selected} "
  zle redisplay
}

_minimal_fzf_directories() {
  (( $+commands[fzf] )) || {
    zle -M 'fzf is not installed'
    return 0
  }

  local selected
  local -a directory_command

  if (( $+commands[fd] )); then
    directory_command=(fd --type d --hidden --follow --exclude .git)
  elif (( $+commands[fdfind] )); then
    directory_command=(fdfind --type d --hidden --follow --exclude .git)
  else
    directory_command=(find . -type d -not -path '*/.git/*')
  fi

  selected=$("${directory_command[@]}" 2>/dev/null | fzf \
    --height=40% --layout=reverse --border) || return 0

  builtin cd -- "$selected" || return
  zle reset-prompt
}

zle -N history-substring-search-up
zle -N history-substring-search-down
zle -N _native_backward_kill_zword
zle -N _native_cd_up
zle -N _native_cd_down
zle -N _minimal_fzf_history
zle -N _minimal_fzf_files
zle -N _minimal_fzf_directories
zle -N killfzf

bindkey '^A' beginning-of-line              # Ctrl-A: move to the beginning of the line.
bindkey '^E' end-of-line                    # Ctrl-E: move to the end of the line.
bindkey '^W' backward-kill-word             # Ctrl-W: delete the previous word.
bindkey '^U' backward-kill-line             # Ctrl-U: delete from the cursor to the line start.
bindkey '^H' backward-kill-word             # Ctrl-H/Ctrl-Backspace: delete the previous shell word.
bindkey '\e^H' _native_backward_kill_zword # Ctrl-Alt-Backspace variant: delete the previous path segment.
bindkey '\e^?' _native_backward_kill_zword # Alt-Backspace variant: delete the previous path segment.

bindkey '^_' undo   # Ctrl-/: undo the last line edit.
bindkey '^[[Z' undo # Shift-Tab: undo the last line edit.
bindkey '\e/' redo # Alt-/: redo the last undone line edit.

bindkey '\e[1;3A' _native_cd_up # Alt-Up: change to the parent directory.
bindkey '\e[1;3B' _native_cd_down # Alt-Down: choose and enter a child directory.
bindkey '\e\e[A' _native_cd_up # Alternate Alt-Up terminal sequence: change to the parent directory.
bindkey '\e\e[B' _native_cd_down # Alternate Alt-Down sequence: choose and enter a child directory.

bindkey '^R' _minimal_fzf_history     # Ctrl-R: search command history with fzf.
bindkey '^T' _minimal_fzf_files       # Ctrl-T: insert a file selected with fzf.
bindkey '\ec' _minimal_fzf_directories # Alt-C: choose and enter a directory with fzf.
bindkey '^K' killfzf                  # Ctrl-K: select and signal processes with fzf.
bindkey '\ek' kill-line              # Alt-K: delete from the cursor to the line end.

bindkey '^[[A' history-substring-search-up   # Up: find the previous history entry containing the buffer.
bindkey '^P' history-substring-search-up     # Ctrl-P: find the previous history entry containing the buffer.
bindkey '^[[B' history-substring-search-down # Down: find the next history entry containing the buffer.
bindkey '^N' history-substring-search-down   # Ctrl-N: find the next history entry containing the buffer.
[[ -n ${terminfo[kcuu1]:-} ]] &&
  bindkey "${terminfo[kcuu1]}" history-substring-search-up # Terminal Up: substring history search.
[[ -n ${terminfo[kcud1]:-} ]] &&
  bindkey "${terminfo[kcud1]}" history-substring-search-down # Terminal Down: substring history search.
bindkey -M vicmd k history-substring-search-up   # Vim command k: previous matching history entry.
bindkey -M vicmd j history-substring-search-down # Vim command j: next matching history entry.
