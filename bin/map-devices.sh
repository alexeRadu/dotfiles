#!/usr/bin/bash

echo "Resetting all devices"
for port in {0..7}; do
    power-off ${port}
done

filepath="/home/radu/.devices.json"

# remove any old file
rm -Rf $filepath

echo "[" > /home/radu/.devices.json

for port in {0..7}; do
    power-on ${port}
    sleep 1

    device=$(jld | grep -o --color=never -e '[0-9]\{5,15\}')

    power-off ${port}

    if [ -n "${device}" ]; then
        echo "Found device ${device} on port ${port}"
        echo "  {" >> $filepath
        echo "      \"id\": ${device}," >> $filepath
        echo "      \"port\": ${port}" >> $filepath
        echo "  }" >> $filepath
    fi
done

echo "]" >> $filepath
