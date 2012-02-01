#!/bin/sh

. /etc/X11/xinit/xinitrc.d/*

if [ -d /etc/X11/xinit/xinitrc.d ]; then
  for f in /etc/X11/xinit/xinitrc.d/*; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

xset +fp ~/.fonts
xsetroot -cursor_name left_ptr

if [ `hostname` == "fool" ]; then
    jack_control start
    ffado-dbus-server &
fi

nitrogen --restore
xrdb ~/.Xdefaults
# xcompmgr -cCfF -r7 -o 0.65 -l-10 -t-8 -D2 -I 0.020 -O 0.020
trayer --edge top --align right --margin 100 --height 16 --padding 1 --widthtype request --transparent true --tint 0x000000 --alpha 0 &
nm-applet &

# capslock into escape, swap alt/win keys
# xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
xmodmap ~/.xmodmap

# Dim screen
xbacklight -set 85

# exec gnome-session
# exec startkde
# exec startxfce4
# ...or the Window Manager of your choice

if [ -f "$HOME/.xinitrc_local" ]; then
    . ~/.xinitrc_local
fi

exec ck-launch-session dbus-launch xmonad
