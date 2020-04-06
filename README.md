# Swap

A Simple script to create swap file in Linux

Disclamer: This script may not work on every GNU/Linux distro. 

## Usage:
Run the script directly in shell via runnig: 

```
curl https://raw.githubusercontent.com/bhardwajkonark/Swap/master/swap.sh | sudo sh -s <size of swap in GB> <Swap file Path (Optional)>
# or
wget -qO- https://raw.githubusercontent.com/bhardwajkonark/Swap/master/swap.sh | sudo sh -s <size of swap in GB> <Swap file Path (Optional)>
```
Step 1: Download the main script:
```
wget https://raw.githubusercontent.com/bhardwajkonark/Swap/master/swap.sh  -O swap.sh
# or
curl https://raw.githubusercontent.com/bhardwajkonark/Swap/master/swap.sh  -o swap.sh
```
Step 2: Run the file with the following format:
```
sh swap.sh <size of swap in GB> <Swap file Path (Optional)>
```

Example (with 4Gb):
```
sh swap.sh 4
```

The default path for the swap file is /swapfile. If you wish to change this, simply add the file location (file must not exist) to the command:
```
sh swap.sh 4 /swap
```