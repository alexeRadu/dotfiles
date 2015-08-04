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

HOMEDIR="~/"
update() {
	cp bashrc $HOMEDIR/.bashrc
	cp vimrc $HOMEDIR/.vimrc
	cp gitconfig $HOMEDIR/.gitconfig
}

save() {
	cp $HOMEDIR/.bashrc bashrc
	cp $HOMEDIR/.vimrc vimrc
	cp $HOMEDIR/.gitconfig gitconfig
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
