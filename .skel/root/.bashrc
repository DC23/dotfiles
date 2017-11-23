# Check for an interactive session
[ -z "$PS1" ] && return

# Source our custom functions
if [ -f "${HOME}/.bash_functions" ]; then
    source "${HOME}/.bash_functions"
fi

# environment variables
HOSTNAME=`hostname`
export GREP_COLOR="1;33"
EDITOR="vim"
export EDITOR

# some aliases
alias ls='ls --group-directories-first --color=auto'
alias la='ls -A'
alias ll='ls -Alh'
alias l='ls -lh'
alias dmls='dmls -lah'
alias bc='bc -l'
alias df='df -h'
alias du='du -h'
alias du1='du --max-depth=1'
alias du2='du --max-depth=2'
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias free='free -m'
alias quota='quota -s'
alias git='git --no-pager'
alias pacman="pacman --color=always"
alias tree="tree -C"
