# Check for an interactive session
[ -z "$PS1" ] && return

# Set our prompt.
if [ -f "${HOME}/.bash_prompt" ]; then
    source "${HOME}/.bash_prompt"
fi

# Source our custom functions
if [ -f "${HOME}/.bash_functions" ]; then
    source "${HOME}/.bash_functions"
fi

# environment variables
HOSTNAME=`hostname`
export PATH="~/bin:$PATH"
export GREP_COLOR="1;33"
export EDITOR="vim"
export ASKAP_DOCKER_BASE_DIR="${HOME}/code/askap-dockerfiles/"
export HISTCONTROL=ignoreboth:erasedups
export CC=gcc
export GCC_COLORS=1

# some aliases
alias ls='ls --group-directories-first --color=auto'
alias la='ls -Ah'
alias ll='ls -alh'
alias l='ls -lh'
alias dmls='dmls -lah'
alias bc='bc -l'
alias df='df -h'
alias du='du -h'
alias du1='du --max-depth=1 | sort -hr'
alias du2='du --max-depth=2 | sort -hr'
alias grep='grep --color=auto'
alias egrep='grep -E --color=auto'
alias fgrep='grep -F --color=auto'
alias free='free -m'
alias quota='quota -s'
alias ipyqt='ipython qtconsole --colors=linux --pylab=inline'
alias ipyqtw='ipython qtconsole --pylab=inline'
alias gst='git status'
alias gpr='git pull --rebase'
alias gc='git commit'
alias gcm='git commit -m'
alias gcam='git commit -am'
alias ga='git add'
alias gaa='git add --all'
alias gps='git push'
alias rba='rbuild -SMTa -p squash=1 -p cpp11=1'
alias ssq="svn status -q"

# Git colorisation escape codes don't work with the pager
alias git='git --no-pager'

# lazy typist shortcuts for initialising the ASKAPsoft environment.
if [ -f "${HOME}/trunk/initaskap.sh" ]; then
    alias ia='source ~/trunk/initaskap.sh'
    alias cdsms='cd $ASKAP_ROOT/Code/Components/Services/skymodel/service'
fi

# Use bash-completion, if available. This is not enabled by default
# on LMDE or Debian.
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# Alias some programs so that they don't spam a console with warnings that I don't care about
if command_exists gvim ; then
    alias gvim="gvim +'call Enbiggen()'"
    alias gvim-update='gvim +PluginClean +PluginInstall! +qall'
    alias vim-update='vim +PluginClean +PluginInstall! +qall'
fi

# if we have the tree command, turn colorisation on
if command_exists tree ; then
    alias tree="tree -C"
fi

if command_exists R ; then
    alias R="$(which R) --no-save"
fi

if command_exists fortune ; then
    echo
    fortune
    echo
fi
