# sh/ksh initialization

[ -f $HOME/.kshrc.private ] && . $HOME/.kshrc.private

#############################################################################
# ALIASES
#############################################################################

if command -v colorls > /dev/null ; then
    LS='colorls'
    export CLICOLOR=1
else
    LS='ls'
fi

psg() {
	ps faux | grep "$@" | grep -v "grep $@"
}

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
	alias ls='$LS'
	alias ll='$LS -Flho'
	alias cps='sync ; opencvs up ; sync'

	bind '^L'=clear-screen

	# Enable SIGINFO with ^T
	stty status ^T
elif [[ $(uname -s) == "Darwin" ]]; then
	alias ls='$LS -G'
	alias ll='$LS -GFlho'

	psg() {
		ps aux | grep "$@" | grep -v "grep $@"
	}

	bind '^L'=clear-screen
	export MACPATH=/opt/homebrew/bin/:/opt/homebrew/sbin
elif [[ $(uname -s) == "FreeBSD" ]]; then
	alias ls='$LS -G'
	alias ll='$LS -GFlho'

	bind '^L'=clear-screen

	psg() {
		ps daux | grep "$@" | grep -v "grep $@"
	}

	# Enable SIGINFO with ^T
	stty status ^T

	export TERM=xterm-256color
fi

if [[ $HIGHDPI -eq 1 ]]; then
	alias mpv='mpv --no-audio-display --audio-channels=stereo --geometry=50%+1430+300 --sub-scale=0.5 --demuxer-max-bytes=400000KiB'
else
	alias mpv='mpv --no-audio-display --audio-channels=stereo --geometry=50%+950+200 --sub-scale=0.7 --demuxer-max-bytes=400000KiB'
fi

alias .2='cds ../..'
alias .3='cds ../../..'
alias .4='cds ../../../..'
alias j='jump'
alias c='cvs'
alias g='got'
alias h='history -60 | sort -k2 | uniq -f2 | sort -bn'
alias sudo='sudo -H'
alias mc='mc --color'
alias pwgen='pwgen -s'
alias pkg_add='pkg_add -V'
alias dt='dtoggle'
alias tty-clock='tty-clock -s -c'
alias chromium='chromium --disk-cache-dir=/tmp'
alias open="xdg-open"
alias ffplay='ffplay -hide_banner'
alias gps='sync ; git pull ; sync'
alias gops='sync ; got fetch && got up; sync'
alias cal='cal -m -w'
alias ed='ed -p*'
alias qw='pkill -9 xidle'
alias cc='cc -fdiagnostics-color'
alias weather='curl http://wttr.in/Karlsruhe'
alias dig='dig +noall +answer +comment'
alias gdb='gdb -q'
alias egdb='egdb -q'
alias vim='vim -p'

#############################################################################
# FUNCTIONS
#############################################################################

# Following three functions from "shell FU by Isaac Levy" presentation
yell() { echo "$0: $*" >&2; }
die()  { yell "$*"; exit 111; }
try()  { "$@" || die "cannot $*"; }

# Quick n dirty hack to generate a RSA key and a X509 cert
gennewcert() {
	[[ -z "$1" ]] && echo "No alias provided" && return

	openssl req -x509 -newkey rsa:4096 -sha256 -days 365 -nodes \
		-keyout $1.key.pem -new -subj /CN=$1 -out $1.cert.pem \
		-addext subjectAltName=DNS:$1
}

# Neat trick from https://github.com/lf94/peek-for-tmux/blob/master/README.md
p() {
	tmux split-window -p 33 more $@ || exit;
}

enablevideoconf() {
	echo "[+] Enable video recording"
	doas sysctl kern.video.record=1
	echo "[+] Enable audio recording"
	doas sysctl kern.audio.record=1
	echo "[+] Set mic to mic2"
	doas mixerctl record.adc-0:1_source=mic2
	echo "[+] Adjust input level"
	sndioctl input.level=0.25
}

disablevideoconf() {
	echo "[+] Disable video recording"
	doas sysctl kern.video.record=0
	echo "[+] Disable audio recording"
	doas sysctl kern.audio.record=0
}

# Connect to a vmm(4) VM which uses the "local interface" networking scheme
vmmssh() {
	if [ -z "$1" ]; then
		echo "Usage: vmmssh <name of the vmm VM> [user]"
		echo ""
		echo "If no user name is provided, root is used"
		return
	fi

	local _user="${2:-root}"
	local _id=$(vmctl show $1| tail -1 | awk '{ print $1}')

	if [ "${_id}" = "ID" ]; then
		echo "No VM named $1 found"
		return
	fi

	ssh -o StrictHostKeyChecking=no -l ${_user} 100.64.${_id}.3
}

checklatestsnap() {
	ftp -MVo- "$(egrep -m 1 "^(ftp|http|https)" /etc/installurl)/snapshots/$(uname -m)/BUILDINFO"
	ftp -MVo- http://ftp.openbsd.org/pub/OpenBSD/snapshots/$(uname -m)/BUILDINFO
}

lostandfoundcheck() {
	for mp in $(mount -t ffs | cut -d ' ' -f 3); do
		[[ -d ${mp}/lost+found ]] && echo "${mp}/lost+found exists"
	done
}

kshrc() {
	. $HOME/.kshrc
}

updatesrc() {
	if [ ! -d "/var/git" ]; then
		local _oldpwd="$PWD"
		cd /usr/src && {
			sync && git pull ; sync
		}
		cd /usr/ports && {
			sync && git pull ; sync
		}
		cd "$_oldpwd"
	else
		local _oldpwd="$PWD"
		cd /var/git/src.git && {
			sync && got fetch; sync
		}
		cd /usr/src && {
			sync && got up && sync
		}
		cd /var/git/ports.git && {
			sync && got fetch; sync
		}
		cd /usr/ports && {
			sync && got up && sync
		}
		cd "$_oldpwd"
	fi
}

updatepkgs() {
	local _option="" _args=$1
	if [[ -n $(sysctl -n kern.version | cut -d ' ' -f2 | grep beta) ]]; then
		_option="-D snap"
	fi

	sync && doas pkg_add -ui $_option $_args
	sync

	return

	if [ ! -d /var/pkg_mirror ]; then
		doas mkdir /var/pkg_mirror
	fi
	doas mount_nfs -s -a 4 -T -r 32768 -w 32768 -o noatime,ro,intr mx.xosc.net:/pkg /var/pkg_mirror
	doas umount /var/pkg_mirror/
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
	local _filter1='internet'
	local _filter2='icmp|raw|<-|->'

	if [ "$1" = "-4" ]; then
		_filter2="internet6|${_filter2}"
	elif [ "$1" = "-6" ]; then
		_filter1="internet6"
	fi

	printf "%-10s %-13s %-5s %-5s %-9s %s\n" "USER" "COMMAND" "PID" "PROTO" "FAMILY" "LOCAL ADDRESS"
	fstat | grep "${_filter1}" | grep -vE "${_filter2}" | awk '{ printf("%-10s %-13s %5s %-5s %-9s %s\n", $1,$2,$3,$7,$5,$9); }' | sort -u
}

psearch() {
        local pt="/usr/ports"

        [[ -z ${1} ]] && echo "Need a keyword to search for" && return
        [[ ! -d ${pt} ]] && echo "Cannot find ports tree" && return

        cd ${pt} && make search name=${1}
}

sshopen() {
		# The following is only needed on WSL not on other OSes
		[ -f "/proc/version" ] && grep -qE "(Microsoft|WSL)" /proc/version 2> /dev/null
		if [ $? -eq 0 ]; then
			/usr/bin/keychain -q --nogui $HOME/.ssh/id_ed25519
			return
		fi

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

qrcodegen() {
	# Idea from https://dataswamp.org/~solene/2021-03-25-computer-to-phone-text.html
	xclip -o | qrencode -o - > ~/qrclip.png && sxiv -g 600x600 ~/qrclip.png && rm ~/qrclip.png
}

cds() {
	test -z "$1" && cd $HOME && ls -lh && return
	cd "$1" && ls -lah
}

pkg_search() {
	pkglocate "$1" | cut -d ':' -f 1 | sort -u | fzf --preview="pkg_info {}"
}

mkcd() {
	[[ -n $1 ]] || return 0
	[[ -d $1 ]] || mkdir -p "$1"
	[[ -d $1 ]] && builtin cd "$1"
}

cget() {
	curl -OL --compressed "$@"
}

showwifi() {
	ifconfig | grep ieee | awk {'print $3'}
}

# Show infos about my external IP address
showmyipaddress() {
	echo "My external IPv4 : $(ftp -4 -M -o - http://icanhazip.com 2> /dev/null)"
	echo "My external IPv6 : $(ftp -6 -M -o - http://icanhazip.com 2> /dev/null)"
}

calc() {
	echo "scale=3;$@" | bc -l
}

# Copied from https://github.com/agkozak/polyglot/ MIT license
_polyglot_branch_status() {
  POLYGLOT_REF="$(env git symbolic-ref --quiet HEAD 2> /dev/null)"
  case $? in        # See what the exit code is.
    0) ;;           # $POLYGLOT_REF contains the name of a checked-out branch.
    128) return ;;  # No Git repository here.
    # Otherwise, see if HEAD is in a detached state.
    *) POLYGLOT_REF="$(env git rev-parse --short HEAD 2> /dev/null)" || return ;;
  esac

  if [ -n "$POLYGLOT_REF" ]; then
    if [ "${POLYGLOT_SHOW_UNTRACKED:-1}" -eq 0 ]; then
      POLYGLOT_GIT_STATUS=$(LC_ALL=C GIT_OPTIONAL_LOCKS=0 env git status -uno 2>&1)
    else
      POLYGLOT_GIT_STATUS=$(LC_ALL=C GIT_OPTIONAL_LOCKS=0 env git status 2>&1)
    fi

    POLYGLOT_SYMBOLS=''

    case $POLYGLOT_GIT_STATUS in
      *' have diverged,'*) POLYGLOT_SYMBOLS="${POLYGLOT_SYMBOLS}&*" ;;
    esac
    case $POLYGLOT_GIT_STATUS in
      *'Your branch is behind '*) POLYGLOT_SYMBOLS="${POLYGLOT_SYMBOLS}&" ;;
    esac
    case $POLYGLOT_GIT_STATUS in
      *'Your branch is ahead of '*) POLYGLOT_SYMBOLS="${POLYGLOT_SYMBOLS}*" ;;
    esac
    case $POLYGLOT_GIT_STATUS in
      *'new file:   '*) POLYGLOT_SYMBOLS="${POLYGLOT_SYMBOLS}+" ;;
    esac
    case $POLYGLOT_GIT_STATUS in
      *'deleted:    '*) POLYGLOT_SYMBOLS="${POLYGLOT_SYMBOLS}x" ;;
    esac
    case $POLYGLOT_GIT_STATUS in
      *'modified:   '*) POLYGLOT_SYMBOLS="${POLYGLOT_SYMBOLS}!!" ;;
    esac
    case $POLYGLOT_GIT_STATUS in
      *'renamed:    '*) POLYGLOT_SYMBOLS="${POLYGLOT_SYMBOLS}->" ;;
    esac
    case $POLYGLOT_GIT_STATUS in
      *'Untracked files:'*) POLYGLOT_SYMBOLS="${POLYGLOT_SYMBOLS}?" ;;
    esac

    [ -n "$POLYGLOT_SYMBOLS" ] && POLYGLOT_SYMBOLS=" $POLYGLOT_SYMBOLS"

    printf ' (%s%s)' "${POLYGLOT_REF#refs/heads/}" "$POLYGLOT_SYMBOLS"
  fi

  unset POLYGLOT_REF POLYGLOT_GIT_STATUS POLYGLOT_SYMBOLS
}

lpf() {
	local _pf=${1:-/etc/pf.conf}
	doas pfctl -n -f ${_pf} && doas pfctl -F rules && doas pfctl -f ${_pf}
}

# Disable history logging for this shell
nohistory() {
	HISTFILE=/dev/null
}

tog() {
	TOG_COLORS=1 TERM=xterm /usr/local/bin/tog "$@"
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

set -A complete_kill_1 -- -9 -HUP -INFO -KILL -TERM

set -A complete_ifconfig_1 -- $(ifconfig | grep ^[a-z] | cut -d: -f1)

if [ -d /var/db/pkg ]; then
	PKG_LIST=$(/bin/ls -1 /var/db/pkg)
	set -A complete_pkg_info -- $PKG_LIST

	alias dpkgdel="doas pkg_delete"
	set -A complete_dpkgdel_1 -- $PKG_LIST
fi

# relayctl completion.  Second level only for 'show'
set -A complete_relayctl_1 -- monitor show load poll reload stop redirect table host log
set -A complete_relayctl_2 -- summary hosts redirects relays routers sessions

set -A complete_unwindctl_1 -- reload log status

if [ -d /etc/rc.d ]; then
	RCD_LIST=$(/bin/ls /etc/rc.d)
	set -A complete_rcctl_1 -- get getdef set check reload restart stop start disable enable order ls
	set -A complete_rcctl_2 -- $RCD_LIST

	alias drcctl="doas rcctl"
	set -A complete_drcctl_1 -- get getdef set check reload restart stop start disable enable order ls
	set -A complete_drcctl_2 -- $RCD_LIST
fi

set -A complete_tarsnap_1 -- --list-archives --print-stats --fsck --fsck-prune --nuke --verify-config --version --checkpoint-bytes --configfile --dry-run --exclude --humanize-numbers --keyfile --totals

set -A complete_got_1 -- $(got -h 2>&1 | sed -n s/commands://p)

# /tmp/.man-list is generated upon boot by /etc/rc.local with
# find /usr/share/man/ -type f | sed -e 's/.*\///' -e 's/\.[0-9]//' | sort -u
[[ -f /tmp/.man-list ]] && set -A complete_man -- $(cat /tmp/.man-list)

[[ -d $HOME/.marks ]] && set -A complete_j -- $(/bin/ls $HOME/.marks)

#############################################################################
# PROMPT
#############################################################################

_error_code() {
	local _temp=$?
	if [ $_temp -ne 0 ]; then
		echo -n "\033[38;5;1m [$_temp]\033[m"
	fi
}

if [ -z "$SSH_CLIENT" ]; then
	PS1_TRENNER="!!"
	PS1_S=""
else
	PS1_TRENNER="@"
	PS1_S="@"
fi

if [[ $(id -u) -eq 0 ]]; then
	PS1='\\033[30;101m\h\\033[0m \w$(_error_code) \033[38;5;11m\$\033[m '
elif [[ $(whoami) = "xhr" ]] || [[ $(whoami) = "matthiaschmidt" ]]; then
	PS1='\h${PS1_S} \w$(_polyglot_branch_status)$(_error_code) \033[38;5;11m\$\033[m '
else
	PS1='\h$PS1_TRENNER\u \w$(_polyglot_branch_status) [$?]\n\$ '
fi

#############################################################################
# MISC SETTINGS
#############################################################################

set bell-style none

#############################################################################
# VARIABLES
#############################################################################

[ -d $HOME/.keychain ] && . $HOME/.keychain/LWKA-6Q7VRN2-sh

LSCOLORS=Dxfxcxdxbxegedabagacad
HISTSIZE=30000
HISTFILE=$HOME/.sh_history
HISTCONTROL=ignoredups:ignorespace
BLOCKSIZE=M
PATH=$MACPATH:$HOME/Documents/bin:/bin:/sbin:/usr/bin:/usr/sbin:/usr/X11R6/bin:/usr/local/bin:/usr/local/sbin
LESSSECURE=1
PAGER='less -JWAceX'
LESS='-Xa'
GOT_LOG_DEFAULT_LIMIT=5

# better two-finger touchpad scrolling
export MOZ_USE_XINPUT2=1
# opengl acceleration
export MOZ_ACCELERATED=1
# force webrender to enable
export MOZ_WEBRENDER=1

export PATH HOME TERM LSCOLORS HISTSIZE BLOCKSIZE PAGER LESSSECURE PKG_PATH FETCH_CMD
export GOT_LOG_DEFAULT_LIMIT
