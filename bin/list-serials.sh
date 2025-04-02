#!/usr/bin/sh

devices=$(find /sys/bus/usb/devices/usb1/ -name bConfigurationValue)
# echo $devices

# Select only JLink Devices
for dev in $devices; do
    dev_dir=$(echo $dev | sed s,bConfigurationValue,,)

    if [ -n "$(cat $dev_dir/uevent | grep "PRODUCT=1366")" ]; then
        serial="$(cat $dev_dir/serial)"
        tty="$(grep -r '^DEVNAME=' --include uevent $dev_dir | grep tty | cut -d'=' -f2)"
        echo "$serial $tty"
    fi
done
