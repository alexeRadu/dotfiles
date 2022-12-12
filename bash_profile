#!/bin/bash

# If bash has been invoked as a login shell run .bashrc
if [ -f ~/.bashrc ]; then
	source ~/.bashrc
fi

if [[ -z $DISPLAY ]] && [[ $(tty) == /dev/tty1 ]]; then
    startx
fi
