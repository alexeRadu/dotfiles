vi() {
	IFS=$'\n' files=($(fzf-tmux --margin=10% --border --query="$1" --multi --select-1 --exit-0))
	[[ -n "$files" ]] && ${EDITOR:-vim} "${files[@]}"
}

