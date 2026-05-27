#!/bin/sh

export LANG=ja_JP.UTF-8
export LC_ALL=ja_JP.UTF-8

export GTK_IM_MODULE=uim
export QT_IM_MODULE=uim
export XMODIFIERS=@im=uim
export XIM=uim
#/usr/local/bin/mozc start
uim-xim &
uim-toolbar-gtk3 -1-1 &

#wine#export WINEDEBUG=-all

#106jp#setxkbmap jp

xset r rate 250 40
xset m 5 3
xset s off -dpms s noblank
xrdb -merge ~/.Xresources
xkbcomp -I$HOME/.xkb ~/.xkb/keymap/mykbd $DISPLAY

xsetroot -solid \#5b468f
xclock -update 1 -d -strftime '%Y-%m-%d(%a) %T' -geometry -1+1 -bg \#f8f8f7 &
xterm -geometry 109x5+1+1 -title "コンソール" -e tail -f /var/log/messages &
xfce4-terminal --geometry=80x24+1+97 --title="端末エミュレータ" &
#xpad -s &

##autocutsel -selection PRIMARY &
##autocutsel -selection CLIPBOARD &

##rm -f /tmp/volume_osd_value
##python3.11 $HOME/bin/volume_osd_daemon.py &

#numlock#numlockx

exec fvwm3
