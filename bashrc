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

# switching to neovim
#if [[ $(uname -s) =~ ^Linux ]]; then
#	alias vim=nvim
#fi

# git helpers
source ~/.git-completion.bash

if [[ $(uname -s) =~ ^Linux ]] && [ ! -z $(pgrep -x "i3") ]; then
	source ~/.config/i3/scripts/theme-autocomplete
fi

alias gl="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold yellow)%d%C(reset) %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(green)- %an%C(reset)'"
alias gist="git status"
alias git-store-credentials="git config credential.helper store"

function ga {
	FILES=`git status -s | grep --color=NEVER -e "\(.M\|??\)" | sed "s/^[[:space:]]*//g" | cut -d" " -f2 | fzf --reverse -m --no-info --height=20 --cycle` && git add $FILES
}

function gco {
	FILES=`git status -s | grep --color=NEVER -e "^.M" | sed 's/^[[:space:]]//g' | cut -d" " -f2 | fzf --reverse -m --no-info --height=20 --cycle` && git checkout -- $FILES
}

function gd {
	FILE=`git status -s | grep --color=NEVER -e "^.M" | sed 's/^[[:space:]]//g' | cut -d" " -f2 | fzf --reverse --no-info --height=20 --cycle` && git diff $FILE
}


alias cd..="cd .."
alias ..="cd .."

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export TERM='xterm-256color'
export EDITOR=vim

export PATH=${HOME}/.bin:${PATH}
export PATH=${HOME}/.local/bin:${PATH}

function get_git_branch {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1='\u@\[\033[36m\]\h\[\033[32m\]`get_git_branch`\[\033[33m\] \w\[\033[00m\]\n\\$ '
