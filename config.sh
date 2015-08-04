
is_debian_based=$(ls -l /etc/ | grep lsb-release)
if [ -z $is_debian_base ]; then
	DISTRO=$(cat /etc/system-release | cut -d' ' -f1)
else
	DISTRO=$(cat /etc/lsb-release)
fi

echo $DISTRO
case $DISTRO in 
	Fedora|CentOS|RedHat)
		INSTALL="yum install"
		SEARCH_LOCAL="yum list"
		;;
	
	Ubuntu|Debian)
		INSTALL="apt-get"
		SEARCH_LOCAL=""
		;;

	*)
		echo "Error:Unknown distro"
		exit
		;;
esac

function isInstalled {
	local ret=$($SEARCH_LOCAL $@ >/dev/null)

	if [ -z $ret ]; then
		echo 1
	else
		echo 0
	fi
}

# git
if [ $(isInstalled git) -eq 0 ]; then
	echo "Git is not installed. Installing git."
fi

# git configuration
GIT_USER="Radu Alexe"
GIT_EMAIL="raduandrei.alexe@freescale.freescale.com"
GIT_EDITOR="vim"

git config --global user.name $GIT_USER
git config --global user.email $GIT_EMAIL
git config --global color.ui always
git config --global core.editor $GIT_EDITOR

# vim 
if [ $(isInstalled git) -eq 0 ]; then
	echo "Vim is not installed. Installing vim"
fi

# git configuration

# bash configuration

