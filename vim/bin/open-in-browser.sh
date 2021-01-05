#!/bin/bash

# Date:          05-01-2021
# Author:        Radu Alexe
# Description:   Script to open a file with the browser.
# Prerequisites: xprop, wmctrl, google-chrome

# Get the window id of the current terminal. This way we can switch focus back
# to the terminal once the browser is open
term_win_id=$(xprop -root | grep -e "^_NET_ACTIVE_WINDOW" | cut -d# -f2 | sed 's/ //')

# Open the page using the google-chrome
# TODO: maybe try to use the default browser and have it as option to use a
# certain browser
google-chrome $1 >/dev/null 2>&1 &

# Need to sleep at least 1s in order to be able to switch back focus. Otherwise
# there is not enough time for the browser to open
sleep 1

# Switch back focus to the terminal. The -i option is usefull in order to
# provide a window_id instead of a window_name
wmctrl -i -a ${term_win_id}
