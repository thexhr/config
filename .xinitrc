
# Suck in global xinitrc files
for _ in /etc/X11/xinit/xinitrc.d/*; do
	[[ -f $_ ]] && . "$_"
done

# Import DISPLAY variable into systemd user env
systemctl --user import-environment 'DISPLAY'

# merge Xresources file
[[ -e ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Set Keybard
setxkbmap -layout us -variant intl

exec i3
