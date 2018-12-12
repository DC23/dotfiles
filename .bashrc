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

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# set PATH so it includes user's private bin if it exists
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# environment variables
HOSTNAME=`hostname`
#export PATH="${HOME}/bin:${HOME}/.local/bin:$PATH"
export GREP_COLOR="1;33"
export EDITOR="vim"

export ASKAP_DOCKER_BASE_DIR="${HOME}/code/askap-dockerfiles/"

# scriptabit user plugin directory
if [[ $HOSTNAME == "monkey" || $HOSTNAME == "ashok-bt" ]]; then
    export SCRIPTABIT_USER_PLUGIN_DIR="${HOME}/Dropbox/scriptabit_plugins"
elif [[ $HOSTNAME == "ERIS" ]]; then
    export SCRIPTABIT_USER_PLUGIN_DIR="/mnt/c/Users/Daniel/Dropbox/scriptabit_plugins"
fi

# for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=${HOME}/code

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

# alias `pandoc` to the docker container
alias pandoc='docker run -ti --rm -v ${PWD}:/source --rm silviof/docker-pandoc'

# lazy typist shortcuts for initialising the ASKAPsoft environment.
if [ -f "${HOME}/code/askapsoft/initaskap.sh" ]; then
    alias ia='source ${HOME}/code/askapsoft/initaskap.sh'
    alias cdsms='cd $ASKAP_ROOT/Code/Components/Services/skymodel/service'
fi

if command_exists pipenv ; then
    eval "$(pipenv --completion 2>/dev/null)"
fi

# pyenv configs
if [ -d "${HOME}/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
fi

# load some default modules
if [[ $HOSTNAME = bracewell || $HOSTNAME = pearcey-* || $HOSTNAME = ruby ]]; then
    module load vim
    module load git

    alias lp2='module load python/2.7.11;source /apps/python/2.7.11/bin/virtualenvwrapper_lazy.sh;which python'
    alias lp3='module load python/3.6.1;source /apps/python/3.6.1/bin/virtualenvwrapper_lazy.sh;which python'

    #if [[ $HOSTNAME = bragg-l || $HOSTNAME = bragg-l-test || $HOSTNAME = burnet-login ]]; then
        ## For testing the netcdf-profiling code, I need the libioprof.so location in LD_LIBRARY_PATH
        #export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$HOME/projects/netcdf-profiling/bin/ioprof/lib
    #fi
fi

# Galaxy nodes
if [[ $PAWSEY_OS = cle* ]]; then
    module swap PrgEnv-cray PrgEnv-gnu
    module swap gcc/7.2.0 gcc/4.9.3
    module use /group/askap/modulefiles

    # default Python is too old
    module load python/2.7.14

    # Building askapsoft requires Java
    module load java
    export JAVA_HOME=$JAVA_PATH

    # Allow MPICH to fallback to 4k pages if large pages cannot be allocated
    # This is important for running some of the functional tests
    export MPICH_GNI_MALLOC_FALLBACK=enabled
fi

# Galaxy-ingest
if [[ $PAWSEY_OS = SLES12* ]]; then
    module load sandybridge
    module load python/2.7.10
    module load java
    export JAVA_HOME=$JAVA_PATH
    module load gcc/4.8.5
    module load mvapich
    module load scons
    module load ant
fi

# Debian Hosts
if [[ $HOSTNAME == "monkey" || $HOSTNAME == "sc-29-cdc" ]]; then
    # virtualenv wrapper
    export PROJECT_HOME=$HOME/code
    VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
    if [ -f "/usr/share/virtualenvwrapper/virtualenvwrapper.sh" ]; then
        source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
    fi

    export HISTCONTROL=ignoreboth:erasedups

    CONDA_INSTALL_DIR=$HOME/bin/anaconda
    CONDA_INIT=$CONDA_INSTALL_DIR/etc/profile.d/conda.sh
    if [ -f $CONDA_INIT ]; then
        . $CONDA_INIT
    fi

    export CC=gcc

    # Use bash-completion, if available. This is not enabled by default
    # on LMDE or Debian.
    [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
        . /usr/share/bash-completion/bash_completion

    export SHC_CLIMATE_DATA_PATH=${HOME}/code/hccalc/shc_engine/climate_data

    if command_exists keychain ; then
        # make sure keychain is running
        eval $(keychain --eval --quiet id_rsa)
    fi
fi

if [[ $HOSTNAME == "sc-29-cdc" ]]; then
    export LC_ALL="C.UTF-8"
fi

# Arch Linux hosts
if [[ $HOSTNAME == "scratch" || $HOSTNAME == "belkar" ]]; then
    # virtualenv wrapper
    export PROJECT_HOME=$HOME/code
    VIRTUALENVWRAPPER_PYTHON=/usr/bin/python
    if [ -f "/usr/bin/virtualenvwrapper.sh" ]; then
        source /usr/bin/virtualenvwrapper.sh
    fi

    CONDA_INSTALL_DIR=$HOME/bin/anaconda
    CONDA_INIT=$CONDA_INSTALL_DIR/etc/profile.d/conda.sh
    if [ -f $CONDA_INIT ]; then
        . $CONDA_INIT
    fi

    alias pacman="pacman --color=always"
    alias gvim="gvim +'call Enbiggen()'"
    export HISTCONTROL=ignoreboth:erasedups
    export OMP_NUM_THREADS=2
    export OPENCV_HOME=/usr/include
    export BOOST_HOME=/usr/include
    export BOOST_ROOT=/usr/lib/
    export CC=gcc

    if command_exists keychain ; then
        # make sure keychain is running
        eval $(keychain --eval --quiet id_rsa)
    fi
fi

export GCC_COLORS=1

# Alias some programs so that they don't spam a console with warnings that I don't care about
if command_exists gvim ; then
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

if detect_i3 ; then
    ~/bin/i3-setroot
fi

# Subversion alias for quiet status listings that ignore unversioned files
alias ssq="svn status -q"
