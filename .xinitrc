
[[ -f ~/.Xresources ]] && xrdb -merge ~/.Xresources

# Custom Key mapping
#xbindkeys

# No bell
xset -b

# screen powersave
xset +dpms
# No suspend, no standy, turn off screen after 120 secs
xset dpms 0 0 120

# pulseaudio
start-pulseaudio-x11

# Copy & paste
autocutsel -fork &
autocutsel -selection PRIMARY -fork &

exec i3
