# $OpenBSD: dot.profile,v 1.4 2005/02/16 06:56:57 matthieu Exp $
#
# sh/ksh initialization

#############################################################################
# ALIASE
#############################################################################

alias   ls='colorls -FG'
alias   ll='ls -lo'

#############################################################################
# FUNCTIONS
#############################################################################

psg()
{
	ps aux | grep "$@"
}

cds()
{
	cd "$1" && ls -la
}

pkg_search()
{
	pkg_info -Q "$1"
}

#############################################################################
# COMPLETIONS
#############################################################################

# Mostly copied from 
# https://github.com/qbit/dotfiles/blob/master/common/dot_ksh_completions

PKG_LIST=$(/bin/ls -1 /var/db/pkg)

set -A complete_pkg_delete -- $PKG_LIST
set -A complete_pkg_info -- $PKG_LIST

set -A complete_rcctl_1 -- disable enable get ls order set
set -A complete_rcctl_2 -- $(ls /etc/rc.d)

set -A complete_signify_1 -- -C -G -S -V
set -A complete_signify_2 -- -q -p -x -c -m -t -z
set -A complete_signify_3 -- -p -x -c -m -t -z

#############################################################################
# PROMPT
#############################################################################

if [ -z "$SSH_CLIENT" ]; then
	PS1_TRENNER="!!"
else
	PS1_TRENNER="@"
fi

if [[ $(id -u) -eq 0 ]]; then
	PS1='\\033[36m[\A]\\033[0m \\033[38;5;5m\h\\033[0m$PS1_TRENNER\\033[0;101m\u\\033[0m: \\033[38;5;172m\w\\033[0m [\j] \$ '
else
	PS1='\\033[36m[\A]\\033[0m \\033[38;5;5m\h\\033[0m$PS1_TRENNER\\033[38;5;245m\u\\033[0m: \\033[38;5;172m\w\\033[0m [\j] \$ '
fi

#############################################################################
# VARIABLES
#############################################################################

LSCOLORS=Dxfxcxdxbxegedabagacad
TERM=xterm-256color
HISTSIZE=3000
HISTFILE=$HOME/.sh_history
PATH=$HOME/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:/usr/games:.
export PATH HOME TERM LSCOLORS HISTSIZE
