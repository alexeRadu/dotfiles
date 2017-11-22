#!/bin/bash

is_work_machine() {
	local users=(b47441 B47441)
	local login=$(whoami)

	for user in $users; do
		if [ $user = $login ]; then
			echo 1
			return
		fi
	done
}

is_personal_machine() {
	local users=(radu)
	local login=$(whoami)

	for user in $users; do
		if [ $user = $login ]; then
			echo 1
			return
		fi
	done
}

USERNAME="Radu Alexe"
EDITOR="vim"

if [ -n  "$(is_work_machine)" ]; then
	EMAIL="radu.alexe@nxp.com"
elif [ -n "$(is_personal_machine)" ]; then
	EMAIL="alexeradu2007@gmail.com"
else
	echo "User $(whoami) not in the predefined database. Insert new credentials"

	echo "Username: "; read USERNAME
	echo "Email: "; read EMAIL
	echo "Editor: "; read EDITOR
fi

git config --global user.name "$USERNAME"
git config --global user.email "$EMAIL"
git config --global core.editor "$EDITOR"
