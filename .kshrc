# $Id: .kshrc,v 1.8 2018/03/01 18:41:13 cvs Exp $
#
# sh/ksh initialization

[ -f $HOME/.kshrc.private ] && . $HOME/.kshrc.private

#############################################################################
# ALIASE
#############################################################################

alias ls='colorls -G'
alias ll='colorls -FGlho'
alias j='jump'
alias p='pushd'
alias d='popd'
alias g='git'
alias c='cvs'
alias h='history -60 | sort -k2 | uniq -f2 | sort -bn'
alias sudo='sudo -H'
alias mc='mc --color'
alias pwgen='pwgen -s'
alias mpv='mpv --no-audio-display --audio-channels=stereo'
alias dt='dtoggle'
alias tty-clock='tty-clock -s -c'
alias chromium='chromium --disk-cache-dir=/tmp'
alias open="xdg-open"
alias ffplay='ffplay -hide_banner'
alias gps='sync ; git pull ; sync'
alias cps='sync ; opencvs up ; sync'
alias cal='cal -m -w'

#############################################################################
# FUNCTIONS
#############################################################################

# Idea from https://pestilenz.org/~ckeen/blog/posts/pushpop.txt.html
pushd() {
	# Stack is empty
	if [[ -z $__DIRSTK  ]]; then
		export __DIRSTK="$(pwd):"
	fi

	[[ -z $1 ]] && return 2
	cd $1 || return 1
	DIR=$(pwd)
	export __DIRSTK="$DIR":$__DIRSTK
	echo $__DIRSTK
}

popd() {
	DIR=$(echo $__DIRSTK|cut -f 2 -d:)
	if [[ $DIR != "" ]]; then
		cd $DIR
		export __DIRSTK=$(echo $__DIRSTK|cut -f 2- -d:)
		echo $__DIRSTK
	else
		echo "popd: Directory stack empty."
	fi
}

updatesrc() {
	local _oldpwd=$PWD
	cd /usr/src && {
		sync && git pull && sync
	}
	cd /usr/ports && {
		sync && git pull && sync
	}
	cd $_oldpwd
}

getbsdrd() {
	local _mirror="$(egrep -m 1 "^(ftp|http|https)" /etc/installurl)/snapshots/$(uname -m)"

	ftp -V -o /tmp/bsd.rd "$_mirror/bsd.rd" || return 1
	ftp -V -o /tmp/SHA256.sig "$_mirror/SHA256.sig" || return 1

	cd /tmp && signify -C -p "/etc/signify/openbsd-$(uname -r | tr -d '.')-base.pub" -x /tmp/SHA256.sig bsd.rd
}

getbsdvm() {
	local _mirror="$(egrep -m 1 "^(ftp|http|https)" /etc/installurl)/snapshots/$(uname -m)"

	ftp -V -o /tmp/bsd "$_mirror/bsd" || return 1
	ftp -V -o /tmp/SHA256.sig "$_mirror/SHA256.sig" || return 1

	cd /tmp && signify -C -p "/etc/signify/openbsd-$(uname -r | tr -d '.')-base.pub" -x /tmp/SHA256.sig bsd && doas mv /tmp/bsd /bsd.vm
}

openports() {
        local _proto _un1 _un2 _ip _un3 _un4 _netstat _fstat _allout

        _netstat=$(mktemp '/tmp/openports.XXXXXXXX')
        _fstat=$(mktemp '/tmp/openports.XXXXXXXX')
        _allout=$(mktemp '/tmp/openports.XXXXXXXX')

        netstat -na | grep LISTEN > $_netstat
        fstat | grep "internet" > $_fstat

        while read _proto _un1 _un2 _ip _un3 _un4; do
                _port="${_ip##*.}"
                _ip="${_ip%.*}"
                if [ "${_proto}" = "tcp" ]; then
                        _proc=$(cat $_fstat | grep "${_ip}:${_port}$" | awk {'printf "%s\n", $2'} | uniq)
                        printf "%-20s %-30s %5s %-10s\n" "$_proc" "$_ip" "$_port" "$_proto" >> ${_allout}
                elif [ "${_proto}" = "tcp6" ]; then
                        _proc=$(cat $_fstat | grep "${_port}$" | grep -v "\-\-" | awk {'printf "%s\n", $2'} | uniq)
                        printf "%-20s %-30s %5s %-10s\n" "$_proc" "$_ip" "$_port" "$_proto" >> ${_allout}
                fi
        done < $_netstat
        printf "%-20s %-30s %5s %-10s\n" "PROCESS" "IP" "PORT" "FAMILY"
        cat ${_allout} | sort

        rm $_netstat $_fstat $_allout
}

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

cvs() {
	source_ssh_agent
	/usr/bin/cvs "$@"
}

opencvs() {
	source_ssh_agent
	/usr/bin/opencvs "$@"
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
	pkglocate "$1" | cut -d ':' -f 1 | sort -u
}

mkcd() {
	[[ -n $1 ]] || return 0
	[[ -d $1 ]] || mkdir -p "$1"
	[[ -d $1 ]] && builtin cd "$1"
}

cget() {
	curl -OL --compressed "$@"
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

# Disable history logging for this shell
nohistory() {
	HISTFILE=/dev/null
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

	set -A complete_tpm_1 -- $PASS_LIST usage
	set -A complete_tpm_2 -- $PASS_LIST edit insert show rm

fi

[[ -f $HOME/.ssh/config ]] && set -A complete_ssh -- $(grep ^Host ~/.ssh/config | awk '{ print $2 }')

set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM

set -A complete_ifconfig_1 -- $(ifconfig | grep ^[a-z] | cut -d: -f1)

set -A complete_pkg_delete -- $PKG_LIST
set -A complete_pkg_info -- $PKG_LIST

set -A complete_rcctl_1 -- disable enable get ls order set
set -A complete_rcctl_2 -- $(ls /etc/rc.d)

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
	PS1='\\033[38;5;5m\h\\033[0m$PS1_TRENNER\\033[0;101m\u\\033[0m \\033[38;5;172m\w\\033[0m \$ '
else
	PS1="\033[38;5;245m\h\033[0m$PS1_TRENNER\033[38;5;253m\u\033[0m \033[38;5;14m\w\033[0m \$ "
	#PS1='\\033[38;5;5m\h\\033[0m$PS1_TRENNER\\033[38;5;245m\u\\033[0m \\033[38;5;172m\w\\033[0m [$?] \$ '
fi

#############################################################################
# VARIABLES
#############################################################################

LSCOLORS=Dxfxcxdxbxegedabagacad
TERM=xterm-256color
HISTSIZE=10000
HISTFILE=$HOME/.sh_history
BLOCKSIZE=M
PATH=$HOME/Documents/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:/usr/games
LESSSECURE=1
PAGER='less -JWAce'
export PATH HOME TERM LSCOLORS HISTSIZE BLOCKSIZE PAGER LESSSECURE
