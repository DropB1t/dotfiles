typeset -U path PATH
typeset -a user_paths

user_paths=("$HOME/.local/bin")
[[ -d "$HOME/.opencode/bin" ]] && user_paths+=("$HOME/.opencode/bin")
[[ -d "$HOME/.cargo/bin" ]] && user_paths+=("$HOME/.cargo/bin")
[[ -d "$HOME/.spicetify" ]] && user_paths+=("$HOME/.spicetify")
[[ -d /opt/zig ]] && user_paths+=(/opt/zig)

if [[ -d /usr/local/go ]]; then
  export GOROOT=/usr/local/go
  export GOPATH="${GOPATH:-$HOME/.local/go}"
  user_paths+=("$GOROOT/bin" "$GOPATH/bin")
fi

if [[ -z ${JAVA_HOME:-} && -d /usr/lib/jvm/java-17-openjdk-amd64 ]]; then
  export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
fi
[[ -n ${JAVA_HOME:-} && -d "$JAVA_HOME/bin" ]] && user_paths+=("$JAVA_HOME/bin")

if [[ -d /opt/maven ]]; then
  export M2_HOME=/opt/maven
  export MAVEN_HOME=/opt/maven
  user_paths+=("$M2_HOME/bin")
fi

path=($user_paths $path)
export PATH
unset user_paths

export EDITOR="${EDITOR:-zed --wait}"
export VISUAL="${VISUAL:-$EDITOR}"
[[ -n ${TTY:-} ]] && export GPG_TTY="$TTY"

if (( $+commands[bat] || $+commands[batcat] )); then
  export BAT_THEME=ansi
  export BAT_STYLE='numbers,changes'
  export BAT_PAGER='less -RF'
  export BAT_TABS=4
fi

if (( $+commands[dircolors] )); then
  eval "$(dircolors -b 2>/dev/null)"
fi

[[ -r "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"

# Machine-specific values remain untracked and may override the defaults above.
[[ -r "$HOME/.env.zsh" ]] && source "$HOME/.env.zsh"
