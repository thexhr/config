
# Suck in global xinitrc files
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Import DISPLAY variable into systemd user env
if [ -n $(which systemctl) ]; then
	systemctl --user import-environment 'DISPLAY' &
fi

# merge Xresources file
[[ -e ~/.Xresources ]] && xrdb -merge ~/.Xresources &

start-pulseaudio-x11 &

exec i3
