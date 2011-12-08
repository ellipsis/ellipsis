#!/bin/sh

. /etc/X11/xinit/xinitrc.d/*
#
# ~/.xinitrc
#
# Executed by startx (run your window manager from here)

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
xrdb ~/.Xdefaults &
xcompmgr -c &
nitrogen --restore
nm-applet &
# capslock into escape, swap alt/win keys
# xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
xmodmap ~/.Xmodmap
# exec gnome-session
# exec startkde
# exec startxfce4
# ...or the Window Manager of your choice
exec ck-launch-session xmonad
