#!/bin/tcsh

sudo pkg delete wine wine-gecko wine-mono winetricks 
sudo pkg autoremove
\rm     ~/.config/menus/applications-merged/wine-*
\rm -rf ~/.i386-wine-pkg
\rm     ~/.local/share/mime/application/x-wine*
\rm     ~/.local/share/mime/packages/x-wine*
\rm -rf ~/.local/share/applications/wine
\rm     ~/.local/share/applications/wine-*
\rm     ~/.local/share/desktop-directories/wine-*
\rm -rf ~/.cache/winetricks
\rm -rf ~/.cache/wine
\rm -rf ~/.wine
