#!/usr/bin/env zsh

killfzf() {
  local sig sel
  local -a pids

  # 1) Choose signal (default TERM)
  sig=$(
    print -l TERM HUP INT QUIT KILL \
    | fzf --height 10 --border --prompt="Signal> "
  )
  sig=${sig:-TERM}

  # 2) Pick processes (pgrep -a "" lists all; adjust pattern by passing args to killfzf)
  sel=$(
    pgrep -a "" \
    | fzf --multi --height 20 --border \
          --header="Select process(es) to kill (TAB for multi)" \
          --preview 'ps -p {1} -o pid,user,etime,pcpu,pmem,cmd' \
          --preview-window=right:60%:wrap
  ) || return 1

  # 3) Read the first column (PID) into a Zsh array
  pids=()
  while IFS= read -r line; do
    pids+=("${line%% *}")
  done <<< "$sel"
  # Remove duplicates
  pids=("${(u)pids[@]}")
  # Remove empty entries
  pids=("${(e)pids[@]}")
  # Remove non-numeric entries
  pids=("${(e)pids[@]//[^0-9]/}")

  if (( ${#pids[@]} == 0 )); then
    info_ "No PIDs selected" >&2
    return 1
  fi

  # 4) Kill them
  info_ "Killing PIDs: ${pids[*]} with SIG$sig"
  kill -s "$sig" "${pids[@]}"
  exit $?
}

zle -N killfzf
bindkey '^K' killfzf
