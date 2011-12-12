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

# xrdb ~/.Xdefaults &
# nitrogen --restore
# xcompmgr -c &
# trayer --edge top --align right --margin 100 --height 16 --padding 1 --widthtype request --transparent true --tint 0x000000 --alpha 0 &
# nm-applet &

# capslock into escape, swap alt/win keys
# xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
# xmodmap ~/.Xmodmap

# exec gnome-session
# exec startkde
# exec startxfce4
# ...or the Window Manager of your choice

if [ -f "$HOME/.xinitrc_local" ]; then
    . ~/.xinitrc_local
fi

exec ck-launch-session xmonad
