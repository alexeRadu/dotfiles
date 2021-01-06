#!/bin/bash

# Date:          05-01-2021
# Author:        Radu Alexe
# Description:   Script to open a file with the browser.
# Prerequisites: xprop, wmctrl, google-chrome


if [[ $(uname -s) =~ ^Linux ]]; then
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
elif [[ $(uname -s) =~ ^MINGW ]]; then
	SCRIPT_DIR="$(dirname ${BASH_SOURCE[0]})"
	SCRIPT_TMP_NAME=".tmp.show-window.ps1"
	SCRIPT_TMP_PATH="${SCRIPT_DIR}/${SCRIPT_TMP_NAME}"

	# For MinGW under Windows we use powershell scripts:
	# - get-foreground-wnd.ps1 - to get the foreground window handle
	# - show-window.ps1        - to bring to foreground (show|display) a window
	# The second script is generic and before we use it we replace (using sed)
	# the 'Hwnd' with the actual handle value we obtained for the current window
	# and create a new file which we feed to powershell. Then we remove it.

	# For more details see the following pages:
	# https://social.technet.microsoft.com/Forums/en-US/4d257c80-557a-4625-aad3-f2aac6e9a1bd/get-active-window-info?forum=winserverpowershell
	# https://www.reddit.com/r/PowerShell/comments/4nmegx/bring_hidden_process_back_to_foreground/
	term_win_hwnd=$(powershell -command - < "${SCRIPT_DIR}/get-foreground-wnd.ps1")

	start chrome $1
	# powershell Start-Process chrome $1

	sed -E "s/Hwnd/${term_win_hwnd}/" ${SCRIPT_DIR}/show-window.ps1 > ${SCRIPT_TMP_PATH}

	powershell -command - < ${SCRIPT_TMP_PATH}

	rm ${SCRIPT_TMP_PATH}
else
	echo "Not supported system (yet)"
fi

