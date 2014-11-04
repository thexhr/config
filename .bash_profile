# .bash_profile

# Get the aliases and functions
if [ -f ~/.bashrc ]; then
	. ~/.bashrc
fi

# User specific environment and startup programs

PATH=$PATH:$HOME/bin

export PATH
# Make PATH available to systemd
systemctl --user import-environment PATH

export TERMINAL=urxvtc
