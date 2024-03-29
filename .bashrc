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
if [ -d "$HOME/.local/bin" ] ; then
    PATH="$HOME/.local/bin:$PATH"
fi

# environment variables
HOSTNAME=`hostname`
export GREP_COLOR="1;33"
export EDITOR="vim"
export TEXMFHOME=$HOME/.texmf

# for virtualenvwrapper
export WORKON_HOME=$HOME/.virtualenvs
export PROJECT_HOME=${HOME}/code
export PIPENV_VERBOSITY=-1

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
alias git='git --no-pager'  # Git colorisation escape codes don't work with the pager
alias gst='git status'
alias gpr='git pull --rebase'
alias gcm='git commit -m'
alias gaa='git add --all'
alias gps='git push'
alias gpst='git push && git push --tags'

# Pipenv autocompletion
if command_exists pipenv ; then
    eval "$(pipenv --completion 2>/dev/null)"
fi

# Full update alias 
alias full_update='sudo apt update && sudo apt upgrade --yes && sudo apt autoremove --yes && sudo apt autoclean'

# virtualenv wrapper
VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3
if [ -f "/usr/share/virtualenvwrapper/virtualenvwrapper.sh" ]; then
    echo Using /usr/share/virtualenvwrapper/virtualenvwrapper.sh
    source /usr/share/virtualenvwrapper/virtualenvwrapper.sh
fi
if [ -f "$HOME/.local/bin/virtualenvwrapper.sh" ]; then
    echo Using $HOME/.local.bin/virtualenvwrapper.sh
    source $HOME/.local/bin/virtualenvwrapper.sh
fi

export HISTCONTROL=ignoreboth:erasedups
export CC=gcc

# Use bash-completion, if available. This is not enabled by default
# on LMDE or Debian.
[[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion

if command_exists keychain ; then
    # make sure keychain is running
    eval $(keychain --eval --quiet id_rsa)
fi

# Make sure Ruby gems are installed locally
export GEM_HOME="$HOME/gems"
export PATH="$GEM_HOME/bin:$PATH"

# WSL systems
if [[ $HOSTNAME == "ANNISTON-BM" || $HOSTNAME == "DESKTOP-UVGTNQ3" ]]; then
    shopt -s checkwinsize

    export DISPLAY=:0

    # set variable identifying the chroot you work in (used in the prompt below)
    if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
        debian_chroot=$(cat /etc/debian_chroot)
    fi

    # Note: Windows Subsystem for Linux does not currently apply umask properly.
    if [[ "$(umask)" = "0000" ]]; then
        umask 0022
    fi
fi

export GCC_COLORS=1

# Alias some programs so that they don't spam a console with warnings that I don't care about
if command_exists gvim ; then
    alias gvim-update='gvim +PluginClean +PluginInstall! +qall'
fi
if command_exists vim ; then
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

# pyenv configs
if [ -d "${HOME}/.pyenv" ]; then
    export PYENV_ROOT="$HOME/.pyenv"
    export PATH="$PYENV_ROOT/bin:$PATH"
    if command -v pyenv 1>/dev/null 2>&1; then
        eval "$(pyenv init -)"
    fi
fi
