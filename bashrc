# .bashrc

# User specific aliases and functions

# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# LS colors
alias ls='ls --color'
alias ll='ls -l'
alias la='ls -la'
alias l='clear; ll'
LS_COLORS=$LS_COLORS:'no=00:di=1;35:'
export LS_COLORS

# grep aliases
alias grep='grep --color'
alias grepc='grep  -r --include \*.c --include \*.h --include \*.cpp'
alias grepsh='grep -r --include \*.sh'
alias greppy='grep -r --include \*.py'

# no more annoying beeps
set betll-style none
