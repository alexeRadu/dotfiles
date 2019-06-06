cd ~
git clone https://github.com/alexeRadu/st.git

# install dependencies
pkgs=(make pkgconfig gcc)

for pkg in ${pkgs[@]}; do
	if [ ! -z "$($pkg --version 2>&1 | grep 'command not found')" ]; then
		sudo pacman -Syu $pkg
	fi
done

cd st
make
sudo make install
