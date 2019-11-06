#!/bin/bash

sleep 20 #time (in s) for the DE to start; use ~20 for Gnome or KDE, less for Xfce/LXDE etc
conky -c ~/.Conky2cpu/rings & # the main conky with rings
sleep 10 #time for the main conky to start; needed so that the smaller ones draw above not below (probably can be lower, but we still have to wait 5s for the rings to avoid segfaults)
conky -c ~/.Conky2cpu/cpu &
sleep 5
conky -c ~/.Conky2cpu/mem &
#conky -c ~/.Conky2cpu/notes &
