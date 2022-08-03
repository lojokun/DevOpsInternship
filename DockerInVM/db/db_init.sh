#!/bin/bash

echo "Updating the system..."
sudo apt update
echo "Update complete!"
echo "Downloading docker and net-tools..."
apt install -y docker.io net-tools
echo "Download complete!"

echo "Moving the neccesary files to the current directory..."
mv /tmp/mongod.conf.orig .
mv /tmp/basic_init.sh .
mv /tmp/Dockerfile .
echo "Successfully moved the files!"

echo "Starting mongodb inside docker..."
sudo docker build -t mongodb .
sudo docker run -dp 27017:27017 mongodb
echo "Successfully started mongodb!"