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

# exec gnome-session
# exec startkde
# exec startxfce4
# ...or the Window Manager of your choice
xset +fp ~/.fonts
xsetroot -cursor_name left_ptr
jack_control start
ffado-dbus-server &
xrdb ~/.Xdefaults &
xcompmgr -c &
nitrogen --restore &
xscreensaver &
~/.bin/tray &
# capslock into escape
xmodmap -e 'clear Lock' -e 'keycode 0x42 = Escape'
exec ck-launch-session xmonad
