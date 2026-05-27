#!/bin/tcsh
set wid=`xdotool search --onlyvisible --name Firefox`
xdotool windowactivate $wid
xdotool key Ctrl+l
sleep 1
xdotool type https://radiko.jp/\#\!/live/RN2
sleep 1
xdotool key Return
sleep 5
xdotool key Tab
sleep 1
xdotool key Tab
sleep 1
xdotool key Tab
sleep 1
xdotool key Return
