# Reuse a persistent SSH agent unless one was forwarded or explicitly disabled.
if [[ ${ZSH_DISABLE_SSH_AGENT:-0} != 1 && -z ${SSH_AUTH_SOCK:-} ]] &&
   (( $+commands[ssh-agent] )); then
  typeset _ssh_agent_env="$XDG_CACHE_HOME/zsh/ssh-agent.env"
  typeset -i _ssh_agent_valid=0
  [[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p -- "$XDG_CACHE_HOME/zsh"

  if [[ -r "$_ssh_agent_env" ]]; then
    source "$_ssh_agent_env"
  fi

  if [[ -S ${SSH_AUTH_SOCK:-} ]] &&
     { [[ -z ${SSH_AGENT_PID:-} ]] || kill -0 "$SSH_AGENT_PID" 2>/dev/null; }; then
    _ssh_agent_valid=1
  fi

  if (( ! _ssh_agent_valid )); then
    unset SSH_AUTH_SOCK SSH_AGENT_PID
    eval "$(ssh-agent -s)" >/dev/null
    (
      umask 077
      print -r -- "export SSH_AUTH_SOCK=${(q)SSH_AUTH_SOCK}"
      print -r -- "export SSH_AGENT_PID=${(q)SSH_AGENT_PID}"
    ) >| "$_ssh_agent_env"
  fi

  unset _ssh_agent_env _ssh_agent_valid
fi

# Restore the ~w named directory and the Windows VS Code path under WSL.
if [[ -n ${WSL_DISTRO_NAME:-} || ( -r /proc/sys/kernel/osrelease &&
      "$(</proc/sys/kernel/osrelease)" == *[Mm]icrosoft* ) ]]; then
  typeset _windows_home=''
  typeset _windows_profile=''

  if [[ -n ${WIN_HOME:-} ]]; then
    _windows_home=$WIN_HOME
  elif (( $+commands[cmd.exe] && $+commands[wslpath] )); then
    _windows_profile=$(cmd.exe /c 'echo %USERPROFILE%' 2>/dev/null)
    _windows_profile=${_windows_profile//$'\r'/}
    _windows_home=$(wslpath -u "$_windows_profile" 2>/dev/null)
  fi

  if [[ -d $_windows_home ]]; then
    hash -d w="$_windows_home"
    [[ -d "$_windows_home/AppData/Local/Programs/Microsoft VS Code/bin" ]] &&
      path+=("$_windows_home/AppData/Local/Programs/Microsoft VS Code/bin")
  fi

  unset _windows_home _windows_profile
fi
