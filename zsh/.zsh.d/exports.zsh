
export PATH="$HOME/.local/bin":$PATH
export EDITOR="code --wait"

# Zig
if [ -d "/opt/zig" ]; then
  export PATH="/opt/zig:$PATH"
fi

# Java
if [ -d "/usr/lib/jvm/java-17-openjdk-amd64" ]; then
  export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"
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
[ -s "/home/dropbit/.bun/_bun" ] && source "/home/dropbit/.bun/_bun"

# Bat setup bat theme if /usr/bin/bat exists
if command -v batcat &> /dev/null; then
  export BAT_THEME="1337"
  export BAT_STYLE="numbers,changes"
  export BAT_PAGER="less -RF"
  export BAT_TABS="4"
fi

if [ -d "$HOME/.spicetify" ]; then
  export PATH="$HOME/.spicetify":$PATH
fi

_gen_fzf_default_opts() {
  local color00='#282828'
  local color01='#3c3836'
  local color02='#504945'
  local color03='#665c54'
  local color04='#bdae93'
  local color05='#d5c4a1'
  local color06='#ebdbb2'
  local color07='#fbf1c7'
  local color08='#fb4934'
  local color09='#fe8019'
  local color0A='#fabd2f'
  local color0B='#b8bb26'
  local color0C='#8ec07c'
  local color0D='#83a598'
  local color0E='#d3869b'
  local color0F='#d65d0e'
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
   --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D \
   --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C \
   --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"
}

_gen_fzf_catppuccin() {
  local color00='#1e1e2e'
  local color01='#313244'
  local color02='#414868'
  local color03='#585b70'
  local color04='#cdd6f4'
  local color05='#f5e0dc'
  local color06='#f8bd96'
  local color07='#f2d5cf'
  local color08='#f38ba8'
  local color09='#f2a272'
  local color0A='#f9c74f'
  local color0B='#a6e3a1'
  local color0C='#94e2d5'
  local color0D='#89b4fa'
  local color0E='#cba6f7'
  local color0F='#b9bbcf'
  export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS \
    --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D \
    --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C \
    --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D" 
}

#_gen_fzf_default_opts
