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

# scriptabit user plugin directory
if [[ $HOSTNAME == "pango" || $HOSTNAME == "belkar" || $HOSTNAME == "ashok-bt" ]]; then
    export SCRIPTABIT_USER_PLUGIN_DIR="~/Dropbox/scriptabit_plugins"
elif [[ $HOSTNAME == "ERIS" ]]; then
    export SCRIPTABIT_USER_PLUGIN_DIR="/mnt/c/Users/Daniel/Dropbox/scriptabit_plugins"
fi

# The default Anaconda location
export CONDA_INSTALL_DIR=$HOME/bin/anaconda

# for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=~/code

# some aliases
alias ls='ls --group-directories-first --color=auto'
if [[ $HOSTNAME = CLOUD-KH || $HOSTNAME = Eris ]]; then
    alias ls='ls --color=auto'
fi

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
# Git colorisation escape codes don't work with the pager
alias git='git --no-pager'
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

# lazy typist shortcuts for initialising the ASKAPsoft environment.
if [ -f "${HOME}/trunk/initaskap.sh" ]; then
    alias ia='source ~/trunk/initaskap.sh'
    alias cdsms='cd $ASKAP_ROOT/Code/Components/Services/skymodel/service'
fi

# virtualenv wrapper
export PROJECT_HOME=$HOME/code
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
if [ -f "/usr/share/virtualenvwrapper/virtualenvwrapper.sh" ]; then
    source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
fi

alias gvimb="gvim +'call Enbiggen()'"

export HISTCONTROL=ignoreboth:erasedups

#export OMP_NUM_THREADS=2
#export OPENCV_HOME=/usr/include
#export BOOST_HOME=/usr/include/boost
export CC=gcc

# put Anaconda into the path
#export PATH="$CONDA_INSTALL_DIR/bin:$PATH"

# Use bash-completion, if available. This is not enabled by default
# on LMDE or Debian.
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

# scriptabit
alias sb='scriptabit'

export GCC_COLORS=1

# Alias some programs so that they don't spam a console with warnings that I don't care about
if command_exists gvim ; then
    alias gvim='gvim 2>/dev/null'
    alias gvim-update='gvim +PluginClean +PluginInstall! +qall'
    alias vim-update='vim +PluginClean +PluginInstall! +qall'
fi

if command_exists chromium ; then
    alias chromium='chromium 2>/dev/null'
fi

if command_exists midori ; then
    alias midori='midori 2>/dev/null'
fi

if command_exists idea ; then
    alias idea='idea 2>/dev/null'
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

if command_exists multitail ; then
    alias mtl="multitail -CS l4j --retry"
fi

# Subversion alias for quiet status listings that ignore unversioned files
alias ssq="svn status -q"

if [[ $HOSTNAME = pango ]]; then
    setxkbmap -option "caps:swapescape"
fi
