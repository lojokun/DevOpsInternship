#!/bin/bash

echo "Updating system..."
sudo apt update -y
echo "System done updating!"

echo "Downloading MongoDB..."
sudo apt install -y mongodb
echo "Successfully downloaded MongoDB!"

echo "Modifying mongodb config file..."
sudo mv -f /tmp/mongodb.conf /etc
echo "Successfully modified mongodb config file!"

echo "Starting mongodb service..."
sudo systemctl stop mongodb
sudo systemctl start mongodb
echo "Successfully started MongoDB!"
