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

##############################################################################
# EXPERIMENTAL: Start X via systemd user service
##############################################################################

#systemctl --user set-environment XDG_VTNR=1


[[ `tty` == "/dev/tty1" ]] && \
	(( $UID ))			 && \
	[[ -z $DISPLAY ]]	 && \
	exec startx

#		&& systemctl --user start xorg@0.socket \
#		&& exec systemctl --user start xorg.service
