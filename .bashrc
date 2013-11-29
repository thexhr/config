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
HISTSIZE=2000
HISTFILESIZE=8000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

case "$TERM" in
	xterm)
		# Try to ensure we have 256 colors
		export TERM="xterm-256color"
	;;
esac

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
byobu_prompt_status() { local e=$?; [ $e != 0 ] && echo -e "$e "; }
# Use Ubuntu colors (grey / aubergine / orange)
#PS1="${debian_chroot:+($debian_chroot)}\[\e[38;5;202m\]\$(byobu_prompt_status)\[\e[38;5;245m\]\u\[\e[00m\]@\[\e[38;5;5m\]\h\[\e[00m\]:\[\e[38;5;172m\]\w\[\e[00m\] \$ "

if [ `id -u` -eq 0 ]; then
	if [ -z "$SSH_CLIENT" ]; then
		PS1="${debian_chroot:+($debian_chroot)}\[\e[38;5;202m\]\$(byobu_prompt_status)\[\e[38;5;5m\]\h\[\e[00m\]!\[\e[0;101m\]\u\[\e[00m\]:\[\e[38;5;172m\]\w\[\e[00m\] [\j] # "
	else
		PS1="${debian_chroot:+($debian_chroot)}\[\e[38;5;202m\]\$(byobu_prompt_status)\[\e[38;5;5m\]\h\[\e[00m\]@\[\e[0;101m\]\u\[\e[00m\]:\[\e[38;5;172m\]\w\[\e[00m\] [\j] # "
	fi
else
	if [ -z "$SSH_CLIENT" ]; then
		PS1="${debian_chroot:+($debian_chroot)}\[\e[38;5;202m\]\$(byobu_prompt_status)\[\e[38;5;5m\]\h\[\e[00m\]!\[\e[38;5;245m\]\u\[\e[00m\]:\[\e[38;5;172m\]\w\[\e[00m\] [\j] \$ "
	else
		PS1="${debian_chroot:+($debian_chroot)}\[\e[38;5;202m\]\$(byobu_prompt_status)\[\e[38;5;5m\]\h\[\e[00m\]@\[\e[38;5;245m\]\u\[\e[00m\]:\[\e[38;5;172m\]\w\[\e[00m\] [\j] \$ "
	fi
fi

export GREP_COLORS="ms=01;38;5;202:mc=01;31:sl=:cx=:fn=01;38;5;132:ln=32:bn=32:se=00;38;5;242"
export LESS_TERMCAP_mb=$(printf '\e[01;31m')       # enter blinking mode – red
export LESS_TERMCAP_md=$(printf '\e[01;38;5;180m') # enter double-bright mode – bold light orange
export LESS_TERMCAP_me=$(printf '\e[0m')           # turn off all appearance modes (mb, md, so, us)
export LESS_TERMCAP_se=$(printf '\e[0m')           # leave standout mode
export LESS_TERMCAP_so=$(printf '\e[03;38;5;202m') # enter standout mode – orange background highlight (or italics)
export LESS_TERMCAP_ue=$(printf '\e[0m')           # leave underline mode
export LESS_TERMCAP_us=$(printf '\e[04;38;5;139m')   # enter underline mode – underline aubergine

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
    PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\h!\u: \w\a\]$PS1"
    ;;
*)
    ;;
esac


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

##############################################################################
# Exports
##############################################################################

export EDITOR=vim

##############################################################################
# Aliases
##############################################################################

if [ -f ~/.aliasrc ]; then
    . ~/.aliasrc
fi

if [ -f ~/.aliasrc.private ]; then
	. ~/.aliasrc.private
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