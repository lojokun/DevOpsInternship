#!/bin/bash

apt update
apt install sudo
sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv 9DA31620334BD75D9DCB49F368818C72E52529D4

sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository 'deb [arch=amd64] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.0 multiverse'

sudo apt update
sudo apt install -y mongodb-org

sudo apt-get update
sudo apt-get install -y systemctl

#sudo systemctl start mongod
