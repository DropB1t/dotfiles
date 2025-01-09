
# general use
alias ls='exa --icons'                                              # ls
alias ll='exa -alhb --git --icons'                                   # long
alias la='exa -albhHigUm --time-style=long-iso --git --color-scale'  # all list
alias lt='exa --tree --git --icons --color-scale'                   # tree list

alias clock='rsclock -S -c -f 150'
alias weather="curl http://wttr.in/Pisa"
alias ipinfo="curl --silent https://ipinfo.io | jq"

alias ff="fastfetch"
alias lg="lazygit"
alias bt="btop"

# Colorize grep output (good for log files)
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'  

# Confirm before overwriting something
alias mv='mv -i'
# alias cp='cp -i'
# alias rm='rm -i'

alias h="history"
alias q="exit"
alias cl="clear"
alias ig="grep -i"
alias hig="history | grep -i"
alias skp="sudo kill -9"

alias apt-update='sudo apt update && sudo apt upgrade'

# easier to read disk
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB

alias psmem='ps auxf | sort -nr -k 4 | head -5' # Get top process eating memory
alias pscpu='ps auxf | sort -nr -k 3 | head -5' # Get top process eating cpu

alias c="code ."
alias webc='code . --profile "Web"'
alias dotc='cd $HOME/dotfiles; code .'

function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

gtdiff() {
    git diff --name-only --relative --diff-filter=d | xargs bat --diff
}

update-go() {
    wget "https://go.dev/dl/$(curl 'https://go.dev/VERSION?m=text' | head -n 1).linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$(curl 'https://go.dev/VERSION?m=text' | head -n 1).linux-amd64.tar.gz"
}

update-discord() {
    wget "https://discord.com/api/download/stable?platform=linux&format=deb" -O /tmp/discord.deb
    sudo dpkg -i /tmp/discord.deb
    rm /tmp/discord.deb
}

download_music_from_youtube() {
    yt-dlp -x --audio-format mp3 --audio-quality 0 -o "~/Music/%(title)s.%(ext)s" https://youtu.be/$1
}
