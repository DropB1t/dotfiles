# Logging helpers.
typeset -g RED=$'\e[0;31m'
typeset -g YELLOW=$'\e[0;33m'
typeset -g BLUE=$'\e[0;34m'
typeset -g GREEN=$'\e[0;32m'
typeset -g NC=$'\e[0m'

error_() {
  print -r -- "${RED}[ERROR] $*${NC}"
}

warning_() {
  print -r -- "${YELLOW}[WARNING] $*${NC}"
}

info_() {
  print -r -- "${BLUE}[INFO] $*${NC}"
}

success_() {
  print -r -- "${GREEN}[SUCCESS] $*${NC}"
}

# Navigation and utility functions.
md() {
  if (( $# != 1 )); then
    print -u2 'usage: md DIRECTORY'
    return 2
  fi

  mkdir -p -- "$1" && builtin cd -- "$1"
}

y() {
	local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
	command yazi "$@" --cwd-file="$tmp"
	IFS= read -r -d '' cwd < "$tmp"
	[ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
	command rm -f -- "$tmp"
}

calc() {
  if (( ! $+commands[bc] )); then
    print -u2 'calc: bc is not installed'
    return 1
  fi

  printf '%s\n' "$@" | command bc -l
}

gtdiff() {
  local pager output
  local -a files

  if (( $+commands[bat] )); then
    pager=bat
  elif (( $+commands[batcat] )); then
    pager=batcat
  else
    print -u2 'gtdiff: bat is not installed'
    return 1
  fi

  output=$(command git diff --name-only --relative --diff-filter=d) || return
  [[ -n $output ]] || return 0
  files=("${(@f)output}")
  command "$pager" --diff -- "${files[@]}"
}

killfzf() {
  local command_name sig selection line pid
  local -a pids

  for command_name in fzf ps; do
    (( $+commands[$command_name] )) || {
      warning_ "killfzf: $command_name is not installed" >&2
      return 1
    }
  done

  sig=$(print -l TERM HUP INT QUIT KILL |
    command fzf --height 10 --border --prompt='Signal> ')
  sig=${sig:-TERM}

  selection=$(command ps -eo pid=,user=,etime=,pcpu=,pmem=,command= |
    command fzf --multi --height 20 --border \
      --header='Select process(es) to kill (TAB for multi)' \
      --preview 'ps -p {1} -o pid,user,etime,pcpu,pmem,command' \
      --preview-window=right:60%:wrap) || return 1

  while IFS= read -r line; do
    line=${line##[[:space:]]#}
    pid=${line%%[[:space:]]*}
    [[ $pid == <-> ]] && pids+=("$pid")
  done <<< "$selection"
  pids=("${(u)pids[@]}")

  if (( ! ${#pids} )); then
    info_ 'No PIDs selected' >&2
    return 1
  fi

  info_ "Killing PIDs: ${pids[*]} with SIG$sig"
  kill -s "$sig" "${pids[@]}"
}

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

  export FZF_DEFAULT_OPTS="${FZF_DEFAULT_OPTS:-} \
   --color=bg+:$color01,bg:$color00,spinner:$color0C,hl:$color0D \
   --color=fg:$color04,header:$color0D,info:$color0A,pointer:$color0C \
   --color=marker:$color0C,fg+:$color06,prompt:$color0A,hl+:$color0D"
}

# Update and download helpers.
update-go() {
  local command_name version archive

  for command_name in curl wget sudo tar; do
    (( $+commands[$command_name] )) || {
      print -u2 "update-go: $command_name is not installed"
      return 1
    }
  done

  version=$(command curl -fsSL 'https://go.dev/VERSION?m=text' |
    command head -n 1) || return
  [[ -n $version ]] || {
    print -u2 'update-go: could not determine the latest version'
    return 1
  }

  archive=/tmp/go.tar.gz
  command wget "https://go.dev/dl/${version}.linux-amd64.tar.gz" \
    -O "$archive" || return
  command sudo rm -rf /usr/local/go || return
  command sudo tar -C /usr/local -xzf "$archive" || return
  command rm -f -- "$archive"
}

update-discord() {
  local command_name
  local package=/tmp/discord.deb

  for command_name in wget sudo dpkg; do
    (( $+commands[$command_name] )) || {
      print -u2 "update-discord: $command_name is not installed"
      return 1
    }
  done

  command wget 'https://discord.com/api/download/stable?platform=linux&format=deb' \
    -O "$package" || return
  command sudo dpkg -i "$package" || return
  command rm -f -- "$package"
}

update-delta() {
  local command_name version package

  for command_name in wget jq sudo dpkg; do
    (( $+commands[$command_name] )) || {
      print -u2 "update-delta: $command_name is not installed"
      return 1
    }
  done

  version=$(command wget -qO- \
    https://api.github.com/repos/dandavison/delta/releases/latest |
    command jq -r '.tag_name') || return
  [[ -n $version && $version != null ]] || {
    print -u2 'update-delta: could not determine the latest version'
    return 1
  }

  package=/tmp/git-delta.deb
  command wget \
    "https://github.com/dandavison/delta/releases/download/$version/git-delta_${version}_amd64.deb" \
    -O "$package" || return
  command sudo dpkg -i "$package" || return
  command rm -f -- "$package"
}

update-fastpotify() {
  local command_name download_url package

  for command_name in wget jq flatpak; do
    (( $+commands[$command_name] )) || {
      print -u2 "update-fastpotify: $command_name is not installed"
      return 1
    }
  done

  download_url=$(command wget -qO- \
    https://api.github.com/repos/crmne/fastpotify/releases/latest |
    command jq -r '.assets[] | select(.name | endswith(".flatpak")) | .browser_download_url') || return
  [[ -n $download_url && $download_url != null ]] || {
    print -u2 'update-fastpotify: could not determine the latest release'
    return 1
  }

  package=/tmp/${download_url##*/}
  command wget "$download_url" -O "$package" || return
  command flatpak install --user -y "$package" || return
  command rm -f -- "$package"
}

update-yt-dlp() {
  (( $+commands[curl] )) || {
    print -u2 'update-yt-dlp: curl is not installed'
    return 1
  }

  mkdir -p -- "$HOME/.local/bin" || return
  command curl -fL \
    https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
    -o "$HOME/.local/bin/yt-dlp" || return
  command chmod a+rx "$HOME/.local/bin/yt-dlp"
}

download_music_from_youtube() {
  local video=${1:-}
  local downloader="$HOME/.local/bin/yt-dlp"

  [[ -n $video ]] || {
    print -u2 'usage: download_music_from_youtube VIDEO_ID'
    return 2
  }
  [[ -x $downloader ]] || {
    print -u2 "download_music_from_youtube: $downloader is not installed"
    return 1
  }
  (( $+commands[ffmpeg] )) || {
    print -u2 'download_music_from_youtube: ffmpeg is not installed'
    return 1
  }

  mkdir -p -- "$HOME/Music" || return
  "$downloader" -x --audio-format mp3 --audio-quality 320K \
    --embed-metadata --embed-thumbnail --convert-thumbnails jpg \
    --parse-metadata "%(artist,uploader)s:%(meta_artist)s" \
    -o "$HOME/Music/%(title)s.%(ext)s" "https://youtu.be/$video"
}

update-ghostty() {
  (( $+commands[curl] )) || {
    print -u2 'update-ghostty: curl is not installed'
    return 1
  }

  command curl -fsSL \
    https://raw.githubusercontent.com/mkasberg/ghostty-ubuntu/HEAD/install.sh |
    command bash
}

update-zig() {
  local command_name
  local install_dir=/opt/zig
  local download_data tarball_url latest_version installed_version
  local temp_dir zig_archive

  for command_name in curl jq sudo tar; do
    (( $+commands[$command_name] )) || {
      error_ "update-zig: $command_name is not installed"
      return 1
    }
  done

  if [[ $OSTYPE != linux* || $(command uname -m) != x86_64 ]]; then
    error_ 'update-zig currently supports x86_64 Linux only'
    return 1
  fi

  print 'Fetching the latest Zig stable version...'
  download_data=$(command curl -fsSL https://ziglang.org/download/index.json) || {
    error_ 'Failed to fetch Zig release information.'
    return 1
  }

  tarball_url=$(print -r -- "$download_data" | command jq -r '
    to_entries
    | map(select(.key != "master"))
    | sort_by(.key | split(".") | map(tonumber))
    | reverse
    | .[0].value."x86_64-linux".tarball
  ')
  latest_version=$(print -r -- "$download_data" | command jq -r '
    to_entries
    | map(select(.key != "master"))
    | sort_by(.key | split(".") | map(tonumber))
    | reverse
    | .[0].key
  ')

  [[ -n $latest_version && $latest_version != null ]] || {
    error_ 'Failed to determine the latest Zig version.'
    return 1
  }
  info_ "Latest version: $latest_version"

  if (( $+commands[zig] )); then
    installed_version=$(command zig version)
    if [[ $installed_version == $latest_version ]]; then
      success_ "Zig is already up-to-date at version $installed_version."
      return 0
    fi
  else
    warning_ 'Zig is not installed. Proceeding with installation...'
  fi

  [[ -n $tarball_url && $tarball_url != null ]] || {
    error_ 'Failed to fetch the Zig tarball URL.'
    return 1
  }

  temp_dir=$(mktemp -d) || return
  zig_archive="$temp_dir/zig.tar.xz"
  print "Downloading Zig from $tarball_url..."
  command curl -fL -o "$zig_archive" "$tarball_url" || {
    command rm -rf -- "$temp_dir"
    return 1
  }

  info_ "Installing Zig to $install_dir..."
  command sudo rm -rf "$install_dir" || return
  command sudo mkdir -p "$install_dir" || return
  command sudo tar -xJf "$zig_archive" --strip-components=1 \
    -C "$install_dir" || {
    error_ 'Failed to extract and install Zig.'
    command rm -rf -- "$temp_dir"
    return 1
  }

  command rm -rf -- "$temp_dir"
  success_ "Zig installed successfully to $install_dir."
}
