#!/usr/bin/bash

devcount=6

# close everydevice
for ((i=1; i<=$devcount; i++)); do
    poff $i
done

# open one by one and extract info
rm -f ~/.devices; touch ~/.devices
for ((i=1; i<=$devcount; i++)); do
    pon $i; sleep 0.5

    dev_num=$(jld | grep --color=never -ohe "[0-9]\{8,10\}")
    # dev_port=$(sudo dmesg | tail -3 | grep --color=never -o "ttyACM[0-9]")

    echo "$i $dev_num" >> ~/.devices
    echo "$i $dev_num"

    poff $i
done
