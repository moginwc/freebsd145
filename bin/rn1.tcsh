#!/bin/tcsh
firefox "https://radiko.jp/\#\!/live/RN1" &
sleep 10
set wid=`xdotool search --onlyvisible --name Firefox`
xdotool windowactivate $wid
xdotool key Tab
sleep 1
xdotool key Tab
sleep 1
xdotool key Tab
sleep 1
xdotool key Return
