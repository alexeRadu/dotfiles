# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

tty=`ps -p $$ | tail -n +2 | grep -oE '[^ \/]+$'`
platform=`uname -a | grep -oE '[^ ]+$'`

# LS colors
if [ "$tty" = "busybox" ]; then
	alias ls='ls --color=auto'
else
	alias ls='ls --color=auto --group-directories-first'
	alias grep='grep --color'
fi
alias ll='ls -l'
alias la='ls -la'

LS_COLORS=$LS_COLORS:'no=00:di=1;35:'
export LS_COLORS

# clear alias
alias cl='clear'

# alias for bitbake
alias bb='bitbake'

# git helpers
source ~/.git-completion.bash
source ~/.config/i3/scripts/theme-autocomplete

alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold yellow)%d%C(reset) %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(green)- %an%C(reset)'"
alias gist="git status"
alias git-store-credentials="git config credential.helper store"

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export TERM='xterm-256color'
export EDITOR=vim

export PATH=${HOME}/.bin:${PATH}

if [ "${platform}" = "Cygwin" ]; then
	export DISPLAY=':0.0'
fi

if [ "$LOGNAME" == "b47441" ]; then
	alias home='cd /home/b47441'

	# env variables
	HOME=/homedir/b47441
	PWD=/homedir/b47441
	PATH=${PATH}:/home/b47441/usr/bin

	# other aliases
	alias myboards='lars list boards | grep "Alexe Radu Andrei-B47441"'
fi

function get_git_branch {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1='\u@\[\033[36m\]\h\[\033[32m\]`get_git_branch`\[\033[33m\] \w\[\033[00m\]\n\\$ '
