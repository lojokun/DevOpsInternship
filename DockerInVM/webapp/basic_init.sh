#!/bin/bash

apt update
apt install sudo #instalarea sudo

sudo apt update
sudo apt install -y software-properties-common  #pregatire pentru instalarea aptitude
sudo apt install -y aptitude  #instalare aptitude

sudo apt install net-tools  #instalare net-tools pentru utilizarea ifconfig
sudo apt install nano #instalare nano