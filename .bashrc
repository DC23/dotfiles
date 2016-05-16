# Check for an interactive session
[ -z "$PS1" ] && return

# set our prompt
#PS1='\u@\h \W \$ '

# Source our custom functions
if [ -f "${HOME}/.bash_functions" ]; then
    source "${HOME}/.bash_functions"
fi

# environment variables
HOSTNAME=`hostname`
export PATH="~/bin:$PATH"
export GREP_COLOR="1;33"
EDITOR="vim"
export EDITOR

# The default Anaconda location
export CONDA_INSTALL_DIR=$HOME/bin/anaconda

# for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=~/projects

# some aliases
alias ls='ls --group-directories-first --color=auto'
if [[ $HOSTNAME = FRACTURE-KH || $HOSTNAME = Eris || $HOSTNAME = ASHOK-BT ]]; then
    alias ls='ls --color=auto'
fi

alias la='ls -A'
alias ll='ls -Alh'
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

# load some default modules
if [[ $HOSTNAME = bragg-gpu || $HOSTNAME = pearcey-* || $HOSTNAME = cherax ]]; then
    module load vim
    module load git

    alias lp2='module load python/2.7.10;source /apps/python/2.7.10/bin/virtualenvwrapper_lazy.sh;which python'
    alias lp278='module load python/2.7.8;source /apps/python/2.7.8/bin/virtualenvwrapper_lazy.sh;which python'
    alias lp3='module load python/3.4.3;source /apps/python/3.4.3/bin/virtualenvwrapper_lazy.sh;which python'

    export CONDA_INSTALL_DIR=$DATADIR/miniconda3

    #if [[ $HOSTNAME = bragg-l || $HOSTNAME = bragg-l-test || $HOSTNAME = burnet-login ]]; then
        ## For testing the netcdf-profiling code, I need the libioprof.so location in LD_LIBRARY_PATH
        #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/projects/netcdf-profiling/bin/ioprof/lib
    #fi
fi

if [[ $PAWSEY_OS = cle* ]]; then
    module use /group/askap/modulefiles
    module load askapsoft
    module load askapdata
    module load askappipeline
fi

# Debian Hosts
if [[ $HOSTNAME == "pango" || $HOSTNAME == "belkar" ]]; then
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
    export PATH="$CONDA_INSTALL_DIR/bin:$PATH"
fi

# Arch Linux hosts
if [[ $HOSTNAME == "nibblet" || $HOSTNAME == "puffin" ]]; then
    # virtualenv wrapper
    export PROJECT_HOME=$HOME/code
    VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
    if [ -f "/usr/bin/virtualenvwrapper.sh" ]; then
        source /usr/bin/virtualenvwrapper.sh
    fi

    alias pacman="pacman --color=always"
    alias gvimb="gvim +'call Enbiggen()'"

    export HISTCONTROL=ignoreboth:erasedups

    export OMP_NUM_THREADS=2
    export OPENCV_HOME=/usr/include
    export BOOST_HOME=/usr/include/boost
    export CC=gcc
fi

export GCC_COLORS=1

# Alias gvim and chromium so that they don't spam a console with warnings that I don't care about
if command_exists gvim ; then
    alias gvim='gvim 2>/dev/null'
    alias gvim-update='gvim +PluginClean +PluginInstall! +qall'
fi

if command_exists chromium ; then
    alias chromium='chromium 2>/dev/null'
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

if [[ $HOSTNAME = pango ]]; then
    setxkbmap -option "caps:swapescape"
fi
