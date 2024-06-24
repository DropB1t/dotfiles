
# general use
alias ls='exa --icons'                                              # ls
alias ll='exa -alb --git --icons'                                   # long
alias la='exa -albhHigUm --time-style=default --git --color-scale'  # all list
alias lt='exa --tree --git --icons --color-scale'                   # tree list

alias clock='rsclock -S -c -f 150'
alias weather="curl http://wttr.in/Pisa"
alias ipinfo="curl --silent https://ipinfo.io | jq"

alias ff="fastfetch"

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

# easier to read disk
alias df='df -h'     # human-readable sizes
alias free='free -m' # show sizes in MB

alias psmem='ps auxf | sort -nr -k 4 | head -5' # Get top process eating memory
alias pscpu='ps auxf | sort -nr -k 3 | head -5' # Get top process eating cpu

alias c="code ."
alias wcode='code . --profile "Web"'

alias titanium='ssh rymarchuk@131.114.50.215'

function md() { [[ $# == 1 ]] && mkdir -p -- "$1" && cd -- "$1" }
compdef _directories md

updatego() {
    wget "https://go.dev/dl/$(curl 'https://go.dev/VERSION?m=text' | head -n 1).linux-amd64.tar.gz"
    sudo rm -rf /usr/local/go
    sudo tar -C /usr/local -xzf "$(curl 'https://go.dev/VERSION?m=text' | head -n 1).linux-amd64.tar.gz"
}
