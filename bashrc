# .bashrc

[ -z "${PLATFORM}" ] && export PLATFORM=$(uname -s)
[ -f /etc/bashrc ] && . /etc/bashrc

tty=`ps -p $$ | tail -n +2 | grep -oE '[^ \/]+$'`

export PATH=${HOME}/.bin:${PATH}
export PATH=${HOME}/.local/bin:${PATH}
export PATH=${HOME}/local/nvim/bin:${PATH}

export BASH_ENV=$HOME/.bashrc

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

alias lg='lazygit'

ga() {
	FILES=`git status -s | grep --color=NEVER -e "\(.M\|??\)" | sed "s/^[[:space:]]*//g" | cut -d" " -f2 | fzf --reverse -m --no-info --height=20 --cycle` && git add $FILES
}

gco() {
	FILES=`git status -s | grep --color=NEVER -e "^.M" | sed 's/^[[:space:]]//g' | cut -d" " -f2 | fzf --reverse -m --no-info --height=20 --cycle` && git checkout -- $FILES
}

alias cd..="cd .."
alias ..="cd .."

alias mk-ls='make -qpRr | egrep --color=always -e "^[a-z].*:"'
alias d2u='find . -type f -print0 | xargs -0 dos2unix'
alias u2d='find . -type f -print0 | xargs -0 unix2dos'

# nnn configuration
# -----------------------------------------------------------------------------
nn() {
	if [[ "${NNNLVL:-0}" -ge 1 ]]; then
		echo "nnn is already running"
		return
	fi

	export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

	\nnn -Ae "$@"

	if [ -f "$NNN_TMPFILE" ]; then
		. "$NNN_TMPFILE"
		rm -f "$NNN_TMPFILE" > /dev/null
	fi
}
alias n="nn -A -e"

export NNN_BMS="u:/home/radu;d:/home/radu/documents;w:/home/radu/work"
export NNN_PLUG="s:jump"

export LANG="en_US.UTF-8"
export LC_CTYPE="en_US.UTF-8"
export TERM='xterm-256color'
export EDITOR=nvim


# Prompt
# -----------------------------------------------------------------------------
get_git_branch() {
	git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/ (\1)/'
}

export PS1='\u@\[\033[36m\]\h\[\033[32m\]`get_git_branch`\[\033[33m\] \w\[\033[00m\]\n\\$ '


# Fzf
# -----------------------------------------------------------------------------
export FZF_DEFAULT_OPTS='--height=40% --layout=reverse --border'

# Bookmark utility
# -----------------------------------------------------------------------------
sp() {
    cd ${HOME}
    [ -f ".bookmarks" ] && path="$(cat .bookmarks | fzf)"

    if [ ! -z "$path" ]; then
        # cd $path
        n $path
    else
        cd - > /dev/null
    fi
}

bp() {
    local path="$(pwd)"
    cd $HOME

    if [ ! -f ".bookmarks" ]; then
        echo "$path" > .bookmarks
    else
        local query="^${path}$"
        local result=$(cat .bookmarks | grep "$query")
        if [ -z "$result" ]; then
            echo "$path" >> .bookmarks
        fi
    fi

    cd - > /dev/null
}


# Exercism
# -----------------------------------------------------------------------------
if [ -f ~/.config/exercism/exercism_completion.bash ]; then
	source ~/.config/exercism/exercism_completion.bash
fi

# Local settings: these bash settings are specific to each computer I use and
# therefore should not be published on the github
# -----------------------------------------------------------------------------
if [ -f ~/.local_conf.bash ]; then
	source ~/.local_conf.bash
fi

