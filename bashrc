# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# LS colors
alias ls='ls --color --group-directories-first'
alias ll='ls -l'
alias la='ls -la'
alias l='clear; ll'
LS_COLORS=$LS_COLORS:'no=00:di=1;35:'
export LS_COLORS

# clear alias
alias cl='clear'


# grep aliases
alias grep='grep --color'
alias grepc='grep  -r --include \*.c --include \*.h --include \*.cpp'
alias grepsh='grep -r --include \*.sh'
alias greppy='grep -r --include \*.py'

# alias for going to home directory
alias home='cd /home/b47441'

# quickly edit files
alias chbash='vim $HOME/.bashrc'
alias chvim='vim $HOME/.vimrc'

# git helpers
source ~/.git-completion.bash

# no more annoying beeps
set betll-style none

