#!/bin/bash

echo '* make sure the system packages are present:'
if sudo apt install python3 python3-dev python3-pip ; then
	echo System packages installed OK
else
	echo System package install failed
	exit 1
fi
echo

echo '* now use the system pip3 (which is typically very outdated) to install an updated pip to ~/.local'
if pip3 install --user --upgrade pip ; then
	echo pip installed
else
	echo User-local pip install failed
	exit 2
fi
echo

echo '* Confirm pip runs as standard user and is installed to '.local' in your home directory:'
if pip --version ; then
	echo pip test OK
else
	echo pip test failed
	echo 'You may need to add ".local/bin" to your path:'
	echo 'if [ -d "$HOME/.local/bin" ]; then'
	echo '	PATH="$HOME/.local/bin:$PATH"'
	echo 'fi'
	exit 3
fi
echo

echo '* Now use the new pip to install pipenv and virtualenvwrapper:'
if pip install --user --upgrade pipenv virtualenvwrapper ; then
	echo packages installed
else
	echo package install failed
	exit 4
fi
echo

echo '* Confirm pipenv install:'
if pipenv --version ; then
	echo pipenv test OK
else
	echo pipenv test failed
	exit 5
fi
echo

echo Python is installed. Add the following to your .bashrc:
echo
echo 'PATH="$HOME/.local/bin"'
echo 'export PIPENV_VERBOSITY=-1'
echo 'eval "$(pipenv --completion 2>/dev/null)"'
echo 'export WORKON_HOME=$HOME/.virtualenvs'
echo 'export VIRTUALENVWRAPPER_PYTHON=/usr/bin/python3'
echo 'source $HOME/.local/bin/virtualenvwrapper.sh'
