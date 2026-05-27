#!/bin/tcsh

sudo bhyve \
  -c 2 \
  -m 4G \
  -s 0:0,hostbridge \
  -s 1:0,lpc \
  -s 2:0,ahci-cd,./ubuntu-22.04.5-desktop-amd64.iso \
  -s 3:0,virtio-blk,./ubuntu.img \
  -s 4:0,virtio-net,tap0 \
  -s 29,fbuf,tcp=0.0.0.0:5900,w=1024,h=768 \
  -s 30,xhci,tablet \
  -l bootrom,/usr/local/share/uefi-firmware/BHYVE_UEFI.fd \
  -AHP -W \
  ubuntu 
