autoload -Uz add-zsh-hook

typeset -g _minimal_prompt_status=''
typeset -g _minimal_prompt_git=''

_minimal_git_prompt() {
  _minimal_prompt_git=''
  (( $+commands[git] )) || return

  local status_output header branch line
  local -a lines
  local -i staged=0 modified=0 untracked=0

  status_output=$(LC_ALL=C GIT_OPTIONAL_LOCKS=0 command git status \
    --porcelain=v1 --branch --untracked-files=normal 2>/dev/null) || return
  lines=("${(@f)status_output}")
  (( ${#lines} )) || return

  header=${lines[1]#\#\# }
  if [[ $header == 'No commits yet on '* ]]; then
    branch=${header#No commits yet on }
  elif [[ $header == 'Initial commit on '* ]]; then
    branch=${header#Initial commit on }
  elif [[ $header == 'HEAD (no branch)'* ]]; then
    branch="@$(command git rev-parse --short HEAD 2>/dev/null)"
  elif [[ $header == 'HEAD (detached at '* ]]; then
    branch="@${${header#HEAD (detached at }%)}"
  else
    branch=${header%%...*}
  fi

  for line in "${lines[@]:1}"; do
    if [[ ${line[1,2]} == '??' ]]; then
      (( ++untracked ))
      continue
    fi
    [[ ${line[1]} != ' ' ]] && (( ++staged ))
    [[ ${line[2]} != ' ' ]] && (( ++modified ))
  done

  branch=${branch//\%/%%}
  _minimal_prompt_git=" %F{magenta}${branch}%f"
  (( staged )) && _minimal_prompt_git+=" %F{green}+${staged}%f"
  (( modified )) && _minimal_prompt_git+=" %F{yellow}~${modified}%f"
  (( untracked )) && _minimal_prompt_git+=" %F{red}?${untracked}%f"
}

_minimal_prompt_precmd() {
  local last_status=$?
  _minimal_prompt_status=''
  (( last_status )) && _minimal_prompt_status="%F{red}[${last_status}]%f "
  _minimal_git_prompt
}

add-zsh-hook precmd _minimal_prompt_precmd

PROMPT='${_minimal_prompt_status}%F{blue}%~%f${_minimal_prompt_git}
%F{green}❯%f '
RPROMPT=
