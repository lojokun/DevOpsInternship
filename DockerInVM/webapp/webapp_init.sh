#!/bin/bash

echo "Updating the system..."
sudo apt update
echo "Update complete!"

echo "Downloading docker and net-tools..."
apt install -y docker.io net-tools
echo "Download complete!"

echo "Downloading the application..."
git clone https://github.com/LukePeters/User-Login-System-Tutorial
mv User-Login-System-Tutorial app
echo "Download complete!"

echo "Moving the neccesary files in the home directory..."
mv /tmp/Dockerfile .
mv /tmp/basic_init.sh .
chmod +x basic_init.sh
mv /tmp/requirements.txt .
mv /tmp/app.py app/app.py
echo "Successfully moved the files!"

echo "Starting webapp inside docker..."
sudo docker build -t webapp .
sudo docker run -dp 5000:5000 webapp
echo "Successfully started the webapp!"