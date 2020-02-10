#
# ~/.bash_profile
#

if shopt -q login_shell; then
	[[ -f ~/.bashrc ]] && source ~/.bashrc
	[[ -t 0 && $(tty) == /dev/tty1 && ! $DISPLAY ]] && exec startx
else
	exit 1 # non-bash or non-login shell
fi
