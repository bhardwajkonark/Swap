#!/bin/sh

disk_space=$(df -kh . | awk 'FNR==2{print $4}' | grep -oE "[[:digit:]]{1,}")
swap_size=$1
swap_path=$2

check_user() {

    if [ "$(id -u)" -ne 0 ]; then
        echo "This script must be run as root"
        exit 1
    fi

}

swap_path() {

    if [ -z swap_path ]; then
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

    today=$(date +"%d-%m-%y")
    sudo cp /etc/fstab /etc/fstab.bak.$today
    echo "Created backup of current /etc/fstab at /etc/fstab.bak.$today"
    echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab
}

create_swap() {
    check_user
    check_swap
    if [ ! -z $swap_size ]; then
        swap_path
        if [ $disk_space -gt $swap_size ]; then
            sudo fallocate -l ${swap_size}G /swapfile
            sudo chmod 600 $swap_path
            sudo mkswap $swap_path
            sudo swapon $swap_path
            echo $swap_path
            echo "${swap_size}G swap file succesfully created at $swap_path"

            persist_swap

        else

            echo " Not enough Disk space"
            echo " Disk Space : ${disk_space}G "
            exit
        fi

    else
        echo "
AIM: To create a persistance swap file

Usage: $0 <size of swap in GB> <Swap file Path (Optional)>

Example : $0 4 /swapfile
"

read -p "Please enter the swap size :" swap_size_interactive 

 if [ $disk_space -gt $swap_size ]; then
            sudo fallocate -l ${swap_size}G /swapfile
            sudo chmod 600 $swap_path
            sudo mkswap $swap_path
            sudo swapon $swap_path
            echo $swap_path
            echo "${swap_size}G swap file succesfully created at $swap_path"

            persist_swap

        else

            echo " Not enough Disk space"
            echo " Disk Space : ${disk_space}G "
            exit
        fi


    fi
    fi

}

create_swap
