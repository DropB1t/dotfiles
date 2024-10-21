
export PATH="$HOME/.local/bin":$PATH
export EDITOR="code --wait"

# Haskell
[ -f "$HOME/.ghcup/env" ] && . "$HOME/.ghcup/env" # ghcup-env

# Java
if [ -d "/usr/lib/jvm/java-11-openjdk-amd64" ]; then
  export JAVA_HOME="/usr/lib/jvm/java-11-openjdk-amd64"
  export PATH=$JAVA_HOME/bin:$PATH
fi

# Maven
if [ -d "/opt/maven" ]; then
  export M2_HOME=/opt/maven
  export MAVEN_HOME=/opt/maven
  export PATH=$M2_HOME/bin:$PATH
fi

# Golang
if [ -d "/usr/local/go" ]; then
  export GOROOT=/usr/local/go
  export GOPATH=$HOME/.local/go
  export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
fi

# Rust
if [ -d "$HOME/.cargo" ]; then
  export PATH="$HOME/.cargo/bin:$PATH"
fi

# Bun
if [ -d "$HOME/.bun" ]; then
  export BUN_INSTALL="$HOME/.bun"
  export PATH="$BUN_INSTALL/bin:$PATH"
fi

# Bat
if [ -d "$HOME/.local/bin/bat" ]; then
  export BAT_THEME="Catppuccino-mocha"
fi

if [ -d "$HOME/.spicetify" ]; then
  export PATH="$HOME/.spicetify":$PATH
fi

export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

#export STARSHIP_CONFIG="$HOME/.config/starship.toml"

