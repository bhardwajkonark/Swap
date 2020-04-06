#!/bin/sh
disk_space=$(df -kh . | awk 'FNR==2{print $4}' | grep -oE '[0-9]+([.][0-9]+)?' | xargs printf "%.0f\n")
swap_size=$1
swap_path=$2

check_user() {

    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root"
        exit 1
    fi

}

is_num() {
    if [ ! -z $swap_size ]; then

        if ! [ "$1" -eq "$1" ] 2>/dev/null; then
            echo "ERROR: not a number! Swap Size has to be a number" >/dev/stderr
            exit 1
        fi
    fi
}

swap_path() {

    if [ -z $swap_path ]; then
        swap_path="/swapfile"
        echo "Swap path not passed in arguments. Using /swapfile as default swap path"
    fi
}

check_swap() {

    current_swap_size=$(free | awk 'FNR==3{print $2}')

    if [ $current_swap_size -gt 0 ]; then
        echo "Swap already exists. Current swap size = ${current_swap_size} KB "
        exit 1
    fi
}

persist_swap() {

    grep -q "swap" /etc/fstab
    if ! grep -q "swap" /etc/fstab; then
        today=$(date +"%d-%m-%y")
        sudo cp /etc/fstab /etc/fstab.bak.$today
        echo "Created backup of current /etc/fstab at /etc/fstab.bak.$today"
        echo "$swap_path none swap sw 0 0" | sudo tee -a /etc/fstab

    else
        echo "
    
    Swap entry already exists in /etc/fstab. Please remove it and add the following:

    $swap_path none swap sw 0 0

    
    "
    fi
}

create_swap() {

    if [ $disk_space -gt $swap_size ]; then
        sudo fallocate -l ${swap_size}G $swap_path
        sudo chmod 600 $swap_path
        sudo mkswap $swap_path
        sudo swapon $swap_path
        # echo $swap_size
        echo "${swap_size}G swap file succesfully created at $swap_path"

    else

        echo " Not enough Disk space"
        echo " Disk Space : ${disk_space}G "
        exit
    fi

}

run_script() {

    check_user
    check_swap

    if [ ! -z $swap_size ]; then

        swap_path $swap_path

        is_num $swap_size

        create_swap $swap_size $swap_path

        persist_swap $swap_path

    else

        echo "


AIM: To create a persistance swap file

Usage: $0 <size of swap in GB> <Swap file Path (Optional)>

Example : $0 4 /swapfile
"

        swap_path $swap_path

        echo "

Swap Size not passed

Entering Interactive mode.
"

        while [ -z ${swap_size} ]; do
            read -p "Please enter the swap size : " swap_size
        done
        is_num $swap_size

        create_swap $swap_size $swap_path

        persist_swap $swap_path

    fi

}

run_script