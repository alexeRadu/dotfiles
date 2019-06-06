if [ "$EUID" -ne 0 ]; then
	echo "Please run as root"
	exit
fi

if [ ! -z "$(mount /dev/cdrom /mnt 2>&1 | grep 'no medium found')" ]; then
	echo "Please insert Guest Additions CD"
	exit
fi

/mnt/autorun.sh

umount /mnt
eject /dev/cdrom
