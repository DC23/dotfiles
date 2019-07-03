if [[ $HOSTNAME == "FREDDO-BM" ]]; then
    # >>> conda initialize >>>
    # !! Contents within this block are managed by 'conda init' !!
    __conda_setup="$('/home/daniel/.pyenv/versions/miniconda2-latest/bin/conda' 'shell.bash' 'hook' 2> /dev/null)"
    if [ $? -eq 0 ]; then
        eval "$__conda_setup"
    else
        if [ -f "/home/daniel/.pyenv/versions/miniconda2-latest/etc/profile.d/conda.sh" ]; then
            . "/home/daniel/.pyenv/versions/miniconda2-latest/etc/profile.d/conda.sh"
        else
            export PATH="/home/daniel/.pyenv/versions/miniconda2-latest/bin:$PATH"
        fi
    fi
    unset __conda_setup
    # <<< conda initialize <<<
fi
