
# Suck in global xinitrc files
if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Import DISPLAY variable into systemd user env
systemctl --user import-environment 'DISPLAY'

# merge Xresources file
[[ -e ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Set Keybard
setxkbmap -layout us -variant intl

start-pulseaudio-x11 &

exec i3
