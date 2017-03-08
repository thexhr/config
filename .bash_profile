# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH
if [ $(uname) = "Linux" ]; then
	# Make PATH available to systemd
	systemctl --user import-environment PATH
fi

export TERMINAL=urxvtc
