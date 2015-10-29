#!/bin/sh

usage() {
	echo "usage: $(basename $0) [-h] <command>"
	echo ""
	echo "  -h  display this help and exit"
	echo ""
	echo "There are only two commands:"
	echo "  update   Copy configuration files to home directory"
	echo "  save     Copy configuration files from home directory"
}

update() {
	# pull from git
	git pull origin 

	# copy files
	cp bashrc $HOME/.bashrc
	cp vimrc $HOME/.vimrc
	cp gitconfig $HOME/.gitconfig
	cp git-completion.bash $HOME/.git-completion.bash
}

save() {
	cp $HOME/.bashrc bashrc
	cp $HOME/.vimrc vimrc
	cp $HOME/.gitconfig gitconfig
	cp $HOME/.git-completion.bash git-completion.bash

	# save them to git
	git add -u
	git commit -m "snapshot at $(date '+%F %H:%M')"
	git push origin master
}


while :; do
	case $1 in
		-h|-\?|--help)
			usage	
			exit
			;;
		update)
			update
			exit
			;;
		save)
			save
			exit
			;;
		*)
			echo "Error: Unknown command. Use $(basename $0) -h for help"
			break
	esac
done
