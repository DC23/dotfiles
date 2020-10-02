#!/bin/bash

echo '* make sure the system packages are present:'
if sudo apt install --yes curl git gcc make zlib1g-dev libbz2-dev libreadline-dev libsqlite3-dev libssl-dev libffi-dev ; then
    echo System packages installed OK
else
    echo System package install failed
    exit 1
fi
echo

if [ -d "$HOME/.pyenv" ]; then
	echo '* pyenv already installed, updating:'
	cd .pyenv && git pull

else
	echo '* installing latest pyenv from GitHub:'
	if git clone https://github.com/pyenv/pyenv.git $HOME/.pyenv ; then
	    echo pyenv installed OK
	else
	    echo pyenv install failed
	    exit 2
	fi
fi
