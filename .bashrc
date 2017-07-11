# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=3000
HISTFILESIZE=8000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

case "$TERM" in
	xterm)
		# Try to ensure we have 256 colors
		export TERM="xterm-256color"
	;;
esac

# Set visual bell
set bell-style visible

# Set selection for pass password-manager
PASSWORD_STORE_X_SELECTION=primary

##############################################################################
# Color
##############################################################################

#    byobu's bashrc -- colorize the prompt
#    Copyright (C) 2013 Dustin Kirkland
#
#    Authors: Dustin Kirkland <kirkland@byobu.co>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, version 3 of the License.
# Ensure that we're in bash, in a byobu environment
# Use Ubuntu colors (grey / aubergine / orange)

if [ -z "$SSH_CLIENT" ]; then
	PS1_TRENNER="!"
else
	PS1_TRENNER="@"
fi
txtrst='\e[0m'    # Text Reset

if [ `id -u` -eq 0 ]; then
	PS1_USER="\[\e[0;101m\]\u\[${txtrst}\]"
else
	PS1_USER="\[\e[38;5;245m\]\u\[${txtrst}\]"

fi

PS1="\[\e[38;5;202m\]\[\e[38;5;5m\]\h\[${txtrst}\]${PS1_TRENNER}"
PS1+="${PS1_USER}"
PS1+="${PS1_VCS}"
PS1+=" \[\e[38;5;172m\]\w\[${txtrst}\] [\j] \$ "

export GREP_COLORS="ms=01;38;5;202:mc=01;31:sl=:cx=:fn=01;38;5;132:ln=32:bn=32:se=00;38;5;242"

# UBUNTU COLORS
#export LESS_TERMCAP_mb=$(printf '\e[01;31m')       # enter blinking mode – red
#export LESS_TERMCAP_md=$(printf '\e[01;38;5;180m') # enter double-bright mode – bold light orange
#export LESS_TERMCAP_me=$(printf '\e[0m')           # turn off all appearance modes (mb, md, so, us)
#export LESS_TERMCAP_se=$(printf '\e[0m')           # leave standout mode
#export LESS_TERMCAP_so=$(printf '\e[03;38;5;202m') # enter standout mode – orange background highlight (or italics)
#export LESS_TERMCAP_ue=$(printf '\e[0m')           # leave underline mode
#export LESS_TERMCAP_us=$(printf '\e[04;38;5;139m')   # enter underline mode – underline aubergine

# Less Colors for Man Pages
export LESS_TERMCAP_mb=$'\E[01;31m'       # begin blinking
export LESS_TERMCAP_md=$'\E[01;38;5;74m'  # begin bold
export LESS_TERMCAP_me=$'\E[0m'           # end mode
export LESS_TERMCAP_se=$'\E[0m'           # end standout-mode
export LESS_TERMCAP_so=$'\E[38;5;246m'    # begin standout-mode - info box
export LESS_TERMCAP_ue=$'\E[0m'           # end underline
export LESS_TERMCAP_us=$'\E[04;38;5;146m' # begin underline

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;\h!\u: \w\a\]$PS1"
    ;;
*)
    ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

##############################################################################
# Exports
##############################################################################

export EDITOR=vim
export PATH=$HOME/Documents/bin:$PATH

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"

##############################################################################
# Aliases
##############################################################################

if [ -f ~/.aliasrc ]; then
    . ~/.aliasrc
fi

if [ -f ~/.aliasrc.private ]; then
	. ~/.aliasrc.private
fi

if [ -f ~/.aliasrc.work ]; then
	. ~/.aliasrc.work
fi

##############################################################################

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Git completion
if [ -f /usr/share/git/completion/git-prompt.sh ]; then
	source /usr/share/git/completion/git-prompt.sh
fi

# Compression
complete -f -o default -X '*.+(zip|ZIP)'  zip
complete -f -o default -X '!*.+(zip|ZIP)' unzip
complete -f -o default -X '*.+(z|Z)'      compress
complete -f -o default -X '!*.+(z|Z)'     uncompress
complete -f -o default -X '*.+(gz|GZ)'    gzip
complete -f -o default -X '!*.+(gz|GZ)'   gunzip
complete -f -o default -X '*.+(bz2|BZ2)'  bzip2
complete -f -o default -X '!*.+(bz2|BZ2)' bunzip2
complete -f -o default -X '!*.+(zip|ZIP|z|Z|gz|GZ|bz2|BZ2)' extract

_completemarks() {
	local curw=${COMP_WORDS[COMP_CWORD]}
	local wordlist=$(find $MARKPATH -type l -printf "%f\n")
	COMPREPLY=($(compgen -W '${wordlist[@]}' -- "$curw"))
	return 0
}

complete -F _completemarks jump unmark j

[ -f /usr/share/git/completion/git-completion.bash ] && source /usr/share/git/completion/git-completion.bash

##############################################################################
# Functions
##############################################################################

source $HOME/.functions

##############################################################################
# SSH/GPG Agent stuff
##############################################################################

# Suck in GPG agent vars
if [ -e "$HOME"/.gpgssh.env ]; then
	source ~/.gpgssh.env
fi

alias sshclose='pkill -u $USER ssh-agent && echo "SSH-Agents killed."; rm -f "$HOME"/.ssh/`hostname`.agent'

if [ -e "$HOME"/.ssh/`hostname`.agent ]; then
	source "$HOME"/.ssh/`hostname`.agent ;
fi
