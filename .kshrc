# $Id: .kshrc,v 1.9 2019/04/21 08:51:01 cvs Exp $
#
# sh/ksh initialization

[ -f $HOME/.kshrc.private ] && . $HOME/.kshrc.private

#############################################################################
# ALIASE
#############################################################################

if [[ $(uname -s) == "Linux" ]]; then
	alias ls='ls --color=auto -h --file-type -s'
	alias ll='ls -l'
	alias rm='rm --preserve-root --one-file-system -I'
	alias cps='sync ; cvs up ; sync'
	if [ -x /usr/bin/dircolors ]; then
		test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
	fi
	bind -m '^L'=clear'^J'
elif [[ $(uname -s) == "OpenBSD" ]]; then
	alias ls='colorls -G'
	alias ll='colorls -FGlho'
	alias cps='sync ; opencvs up ; sync'

	bind '^L'=clear-screen

	# Enable SIGINFO with ^T
	stty status ^T
fi

alias j='jump'
alias g='git'
alias c='cvs'
alias h='history -60 | sort -k2 | uniq -f2 | sort -bn'
alias sudo='sudo -H'
alias mc='mc --color'
alias pwgen='pwgen -s'
alias mpv='mpv --no-audio-display --audio-channels=stereo --geometry 50%+200+200'
alias dt='dtoggle'
alias tty-clock='tty-clock -s -c'
alias chromium='chromium --disk-cache-dir=/tmp'
alias open="xdg-open"
alias ffplay='ffplay -hide_banner'
alias gps='sync ; git pull ; sync'
alias cal='cal -m -w'
alias ed='ed -p*'
alias qw='pkill -9 xidle'
alias cc='cc -fdiagnostics-color'

#############################################################################
# FUNCTIONS
#############################################################################

# Following three functions from "shell FU by Isaac Levy" presentation
yell() { echo "$0: $*" >&2; }
die()  { yell "$*"; exit 111; }
try()  { "$@" || die "cannot $*"; }

# Neat trick from https://github.com/lf94/peek-for-tmux/blob/master/README.md
p() {
	tmux split-window -p 33 more $@ || exit;
}

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
		sync && git pull ; sync
	}
	cd /usr/ports && {
		sync && git pull ; sync
	}
	cd $_oldpwd
}

updatepkgs() {
	local _option=""
	if [[ -n $(sysctl -n kern.version | cut -d ' ' -f2 | grep beta) ]]; then
		_option="-D snap"
	fi

	sync && doas pkg_add -ui $_option
	sync
}

prepare_upgrade() {
	local _mirror="$(egrep -m 1 "^(ftp|http|https)" /etc/installurl)/snapshots/$(uname -m)"
	if [ "$1" = "snap" ]; then
		local REL=$(uname -r | sed 's/\.//')
		REL=$(($REL+1))
	else
		local REL=$(uname -r | sed 's/\.//')
	fi

	if [ ! -d ${HOME}/64 ]; then
		mkdir ${HOME}/64
	fi

	cd ${HOME}/64 || return 1

	# Fetch files not in SHA256.sig which cannot be verfied
	ftp -V "${_mirror}/SHA256.sig"
	ftp -V "${_mirror}/SHA256"
	ftp -V "${_mirror}/index.txt"

	local SETS="INSTALL.amd64 bsd bsd.mp comp${REL}.tgz man${REL}.tgz
		game${REL}.tgz xbase${REL}.tgz xshare${REL}.tgz xserv${REL}.tgz
		xfont${REL}.tgz base${REL}.tgz"
	for f in $SETS; do
		ftp -V "${_mirror}/${f}"
		signify -C -q -x SHA256.sig ${f} || return 23
	done

	sync

	if [ "$1" = "snap" ]; then
		doas upobsd -u $HOME/Documents/cvs/config.private/sigma/upgrade-sigma-disk
	else
		doas upobsd -u $HOME/Documents/cvs/config.private/sigma/upgrade-sigma-disk
	fi
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
        #local AGPATH="$HOME/.ssh/$(hostname).agent"

        #[[ -f ${AGPATH} ]] && rm -f $AGPATH
        #command ssh-agent -t 345600 | grep -v echo > $AGPATH
        #. $AGPATH

        # Find all public keys...
        for i in $(find $HOME/.ssh/ -maxdepth 1 -name "*.pub"); do
                # ... and strip the .pub suffix
                _key=`echo $i | sed -e 's/\.pub//'`
                command ssh-add $_key
        done
}
cvspsdiff() {
	[ -z "$1" ] && return
	cvsps -q -s "$1" -g | cdiff
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
	command git "$@"
}

source_ssh_agent() {
	# Do nothing
}

source_ssh_agent_old() {
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

#############################################################################
# COMPLETIONS
#############################################################################

# Mostly copied from
# https://github.com/qbit/dotfiles/blob/master/common/dot_ksh_completions


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

if [ -d /var/db/pkg ]; then
	PKG_LIST=$(/bin/ls -1 /var/db/pkg)
	set -A complete_pkg_delete -- $PKG_LIST
	set -A complete_pkg_info -- $PKG_LIST
fi

if [ -d /etc/rc.d ]; then
	set -A complete_rcctl_1 -- disable enable get ls order set
	set -A complete_rcctl_2 -- $(ls /etc/rc.d)
fi

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
	PS1='\h$PS1_TRENNER\\033[0;101m\u\\033[0m \w [$?] \$ '
else
	PS1='\h$PS1_TRENNER\u \w [$?] \$ '
fi

#############################################################################
# VARIABLES
#############################################################################

LSCOLORS=Dxfxcxdxbxegedabagacad
HISTSIZE=10000
HISTFILE=$HOME/.sh_history
BLOCKSIZE=M
PATH=$HOME/Documents/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin:/usr/games
LESSSECURE=1
PAGER='less -JWAce'
export PATH HOME LSCOLORS HISTSIZE BLOCKSIZE PAGER LESSSECURE
