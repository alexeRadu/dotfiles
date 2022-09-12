# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

tty=`ps -p $$ | tail -n +2 | grep -oE '[^ \/]+$'`
platform=`uname -a | grep -oE '[^ ]+$'`

export PATH=${HOME}/.bin:${PATH}
export PATH=${HOME}/.local/bin:${PATH}
export PATH=${HOME}/local/nvim/bin:${PATH}

# LS colors
if [ "$tty" = "busybox" ]; then
	alias ls='ls --color=auto'
else
	alias ls='ls --color=auto --group-directories-first'
	alias grep='grep --color=always --exclude=*.o --exclude=*.a --exclude=*.obj --exclude=*.lib --exclude=*.elf --exclude=*.axf --exclude=*.map --exclude-dir=.svn --exclude-dir=.git'
fi
alias ll='ls -l'
alias la='ls -la'

LS_COLORS=$LS_COLORS:'no=00:di=1;35:'
export LS_COLORS

# clear alias
alias cl='clear'

# alias for bitbake
alias bb='bitbake'

# switching to neovim: alias vim to neovim only if it exists
if [ -n "$(which nvim)" ]; then
	alias vim=nvim
	alias vi=nvim
fi

# git helpers
source ~/.git-completion.bash

if [[ $(uname -s) =~ ^Linux ]] && [ ! -z $(pgrep -x "i3") ]; then
	source ~/.config/i3/scripts/theme-autocomplete
fi

alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold yellow)%d%C(reset) %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(green)- %an%C(reset)'"
alias gs="git status"
alias gd="git diff"
alias git-store-credentials="git config credential.helper store"

function ga {
	FILES=`git status -s | grep --color=NEVER -e "\(.M\|??\)" | sed "s/^[[:space:]]*//g" | cut -d" " -f2 | fzf --reverse -m --no-info --height=20 --cycle` && git add $FILES
}

function gco {
	FILES=`git status -s | grep --color=NEVER -e "^.M" | sed 's/^[[:space:]]//g' | cut -d" " -f2 | fzf --reverse -m --no-info --height=20 --cycle` && git checkout -- $FILES
}

alias cd..="cd .."
alias ..="cd .."

alias mk-ls='make -qpRr | egrep --color=always -e "^[a-z].*:"'
alias d2u='find . -type f -print0 | xargs -0 dos2unix'
alias u2d='find . -type f -print0 | xargs -0 unix2dos'

# nnn configuration
nn() {
	if [[ "${NNNLVL:-0}" -ge 1 ]]; then
		echo "nnn is already running"
		return
	fi

	export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

	\nnn -A -e "$@"

	if [ -f "$NNN_TMPFILE" ]; then
		. "$NNN_TMPFILE"
		rm -f "$NNN_TMPFILE" > /dev/null
	fi
}
alias n="nn -A -e"

export NNN_BMS="u:/home/radu;d:/home/radu/documents;w:/home/radu/work"

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export TERM='xterm-256color'
export EDITOR=nvim


function get_git_branch {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1='\u@\[\033[36m\]\h\[\033[32m\]`get_git_branch`\[\033[33m\] \w\[\033[00m\]\n\\$ '

# source additional functions
# TODO: fix this!
# source ~/.bin/bash_utils/fzf.sh

# Exercism completions
if [ -f ~/.config/exercism/exercism_completion.bash ]; then
	source ~/.config/exercism/exercism_completion.bash
fi

if [ -f ~/.local_conf.bash ]; then
	source ~/.local_conf.bash
fi
