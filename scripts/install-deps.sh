#!/bin/bash

pkgs=(chromium			# currently my browser
	make pkgconf gcc	# usefull for building stuff
	openssh)		# provides: ssh-keygen

echo "Installing packages"

for pkg in ${pkgs[@]}; do
	printf "%-16s : " $pkg

	if [ -z "$(pacman -Qi $pkg 2>/dev/null)" ]; then
		sudo pacman -Sqyu --noconfirm $pkg 2>&1 1>/dev/null
		printf "done\n"
	else
		printf "already exists\n"
	fi
done
