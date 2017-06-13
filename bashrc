# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# LS colors
alias ls='ls --color=auto --group-directories-first'
alias ll='ls -l'
alias la='ls -la'
alias l='clear; ll'
LS_COLORS=$LS_COLORS:'no=00:di=1;35:'
export LS_COLORS

# clear alias
alias cl='clear'

# alias for bitbake
alias bb='bitbake'

# grep aliases
alias grep='grep --color'
alias grepc='grep  -r --include \*.c --include \*.h --include \*.cpp'
alias grepsh='grep -r --include \*.sh'
alias greppy='grep -r --include \*.py'

# other aliases
alias myboards='lars list boards | grep "Alexe Radu Andrei-B47441"'

# git helpers
source ~/.git-completion.bash

# env variables
HOME=/homedir/b47441
PWD=/homedir/b47441
PATH=${PATH}:/home/b47441/usr/bin

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"

alias home='cd /home/b47441'
