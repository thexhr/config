# $OpenBSD: dot.profile,v 1.4 2005/02/16 06:56:57 matthieu Exp $
#
# sh/ksh initialization

#############################################################################
# ALIASE
#############################################################################

alias ls='colorls -G'
alias ll='colorls -FGlho'
alias j='jump'
alias p='pushd'
alias d='popd'
alias g='git'
alias h='history -60 | sort -k2 | uniq -f2 | sort -bn'
alias sudo='sudo -H'
alias mc='mc --color'
alias pwgen='pwgen -s'
alias mpv='mpv --no-audio-display'
alias dt='dtoggle'
alias tty-clock='tty-clock -s -c'
alias netd4='ssh -p 2222 -4 matthias@217.115.13.100'
alias netd='ssh -p 2222 matthias@alpha.xosc.org'
alias netd6='ssh -6 alpha.xosc.org'
alias chromium='chromium --disk-cache-dir=/tmp'
alias open="xdg-open"
alias tarsnap='tarsnap --humanize-numbers -v'
alias openports='netstat -na -f inet |grep LISTEN'
alias !!='fc -s'

#############################################################################
# FUNCTIONS
#############################################################################

psearch() {
        local pt="/usr/ports"

        [[ -z ${1} ]] && echo "Need a keyword to search for" && return
        [[ ! -d ${pt} ]] && echo "Cannot find ports tree" && return

        cd ${pt} && make search name=${1}
}

sshopen() {
        local AGPATH="$HOME/.ssh/$(hostname).agent"

        [[ -f ${AGPATH} ]] && rm -f $AGPATH
        command ssh-agent -t 345600 | grep -v echo > $AGPATH
        . $AGPATH

        # Find all public keys...
        for i in $(find $HOME/.ssh/ -maxdepth 1 -name "*.pub"); do
                # ... and strip the .pub suffix
                _key=`echo $i | sed -e 's/\.pub//'`
                command ssh-add $_key
        done
}

ssh() {
	source_ssh_agent
	/usr/bin/ssh "$@"
}

ssh-add() {
	source_ssh_agent
	/usr/bin/ssh-add "$@"
}

scp() {
	source_ssh_agent
	/usr/bin/scp "$@"
}

sshfs() {
	source_ssh_agent
	/usr/bin/sshfs "$@"
}

git() {
	source_ssh_agent
	/usr/local/bin/git "$@"
}

source_ssh_agent() {
	local AGPATH="$HOME/.ssh/$(hostname).agent"

	[[ -f $AGPATH ]] && . $AGPATH
}

psg() {
	ps aux | grep "$@"
}

cds() {
	cd "$1" && ls -la
}

pkg_search() {
	pkg_info -Q "$1"
}

mkcd() {
	[[ -n $1 ]] || return 0
	[[ -d $1 ]] || mkdir -p "$1"
	[[ -d $1 ]] && builtin cd "$1"
}

cget() {
	ftp "$@"
}

# Show infos about my external IP address
showmyipaddress() {
	echo "My external IPv4 : $(ftp -4 -M -o - http://icanhazip.com 2> /dev/null)"
	echo "My external IPv6 : $(ftp -6 -M -o - http://icanhazip.com 2> /dev/null)"
	echo "My external PTR  : $(ftp -M -o - http://icanhazptr.com 2> /dev/null)"
}

calc() {
	echo "scale=3;$@" | bc -l
}

lpf() {
	local _pf=${1:-/etc/pf.conf}
	doas pfctl -n -f ${_pf} && doas pfctl -F rules && doas pfctl -f ${_pf} 
}

# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html

export MARKPATH=$HOME/.marks
jump() {
    cd -P "$MARKPATH/$1" 2>/dev/null || echo "No such mark: $1"
}
mark() {
    mkdir -p "$MARKPATH"; ln -s "$(pwd)" "$MARKPATH/$1"
}
unmark() {
    rm -i "$MARKPATH/$1"
}
marks() {
    ls -l "$MARKPATH" | sed 's/  / /g' | cut -d' ' -f9- | sed 's/ -/\t-/g' && echo
}


# Bind CTRL+l to clear screen
bind -m '^L'=clear'^J'

#############################################################################
# COMPLETIONS
#############################################################################

# Mostly copied from 
# https://github.com/qbit/dotfiles/blob/master/common/dot_ksh_completions

PKG_LIST=$(/bin/ls -1 /var/db/pkg)

if [ -d ~/.password-store ]; then
	PASS_LIST=$(
		cd ~/.password-store
		find . -type f -name \*.gpg | sed 's/^\.\///' | sed 's/\.gpg$//g'
	)

	set -A complete_tpm -- $PASS_LIST edit insert show rm usage

fi

[[ -f $HOME/.ssh/config ]] && set -A complete_ssh -- $(grep ^Host ~/.ssh/config | awk '{ print $2 }')
set -A complete_make_1 -- install clean repackage reinstall
set -A complete_git_1 -- pull push mpull mpush clone checkout status commit

set -A complete_gpg_1 -- --refresh --receive-keys --armor --clearsign --sign --list-key --decrypt --verify --detach-sig
set -A complete_gpg_2 -- --list-secret-keys --list-keys --fingerprint

set -A complete_pkg_delete -- $PKG_LIST
set -A complete_pkg_info -- $PKG_LIST

set -A complete_rcctl_1 -- disable enable get ls order set
set -A complete_rcctl_2 -- $(ls /etc/rc.d)

set -A complete_signify_1 -- -C -G -S -V
set -A complete_signify_2 -- -q -p -x -c -m -t -z
set -A complete_signify_3 -- -p -x -c -m -t -z

set -A complete_tarsnap_1 -- --list-archives --print-stats --fsck --fsck-prune --nuke --verify-config --version --checkpoint-bytes --configfile --dry-run --exclude --humanize-numbers --keyfile --totals

MAN_LIST=$(find /usr/share/man/ -type f | sed -e 's/.*\///' -e 's/\.[0-9]//' | sort -u)
set -A complete_man -- $MAN_LIST

[[ -d $HOME/.marks ]] && set -A complete_j -- $(/bin/ls $HOME/.marks)

#############################################################################
# PROMPT
#############################################################################

if [ -z "$SSH_CLIENT" ]; then
	PS1_TRENNER="!!"
else
	PS1_TRENNER="@"
fi

if [[ $(id -u) -eq 0 ]]; then
	PS1='\\033[38;5;5m\h\\033[0m$PS1_TRENNER\\033[0;101m\u\\033[0m \\033[38;5;172m\w\\033[0m [$?] \$ '
else
	PS1='\\033[38;5;5m\h\\033[0m$PS1_TRENNER\\033[38;5;245m\u\\033[0m \\033[38;5;172m\w\\033[0m [$?] \$ '
fi

#############################################################################
# VARIABLES
#############################################################################

LSCOLORS=Dxfxcxdxbxegedabagacad
TERM=xterm-256color
HISTSIZE=5000
HISTFILE=$HOME/.sh_history
BLOCKSIZE=M
PATH=$HOME/Documents/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:/usr/games:.
PAGER='less -JW'
export PATH HOME TERM LSCOLORS HISTSIZE BLOCKSIZE PAGER
