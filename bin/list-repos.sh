#!/usr/bin/bash

lstrip() {
    printf '%s\n' "${1##$2}"
}

rstrip() {
    printf '%s\n' "${1%%$2}"
}

# sdk_path=~/work/sdk-next
# sdk_path=~/work/sdk/mcuxsdk-workspace
sdk_path=$(cd .. && pwd)

repo_names=("sdk" \
            "framework-int" \
            "mcux-sdk-middleware-connectivity-framework" \
            "mcu-sdk-examples" \
            "mcu-sdk-examples-int" \
            "mcu-sdk-components" \
            "mcux-devices-wireless" \
            "ethermind" \
            "bluetooth" \
            "bluetooth_private" \
            "ble_cs_algo_private" \
            "ble_controller" \
            "ble-controller-int" \
            "genfsk" \
            "XCVR" \
            "ieee-802.15.4" \
            "ieee-802.15.4_private" \
            "wifi_nxp" \
            "wpa_supplicant-rtos" \
            "fw_bin" \
            "lwip" \
            "zigbee_private" \
            "zigbee" \
        )


repo_paths=("mcuxsdk")

echo "Populating repo paths ... (may take a while)"

for ((i=1;i<${#repo_names[*]};i++)); do
    repo_name=${repo_names[$i]}
    repo_path=$(west list_repo | grep -e "^$repo_name " | cut -d'|' -f3)

    # strip whitespaces
    repo_path=$(lstrip "$repo_path" "[[:space:]]")
    repo_path=$(rstrip "$repo_path" "[[:space:]]")

    repo_paths[i]=$repo_path

    echo "$repo_name: $repo_path"
done

printf "\n\n"

for ((i=0;i<${#repo_names[*]};i++)); do
    repo_path="$sdk_path/${repo_paths[$i]}"
    repo_sha=$(cd $repo_path; git log --format=format:%H -1)

    echo "${repo_names[$i]}: $repo_sha"
done
