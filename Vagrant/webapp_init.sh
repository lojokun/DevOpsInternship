#!/bin/bash

echo "Updating system..."
sudo apt update -y
echo "System done updating!"

echo "Downloading python3.8..."
sudo apt install -y software-properties-common
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update -y
sudo apt install -y python3.8
echo "Python 3.8 successfully downloaded!"

echo "Adding python 3.8 to path..."
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3.8 1
echo "Successfully added python 3.8 to path!"

echo "Cloning the application from git..."
git clone https://github.com/LukePeters/User-Login-System-Tutorial
echo "Successfully cloned the app!"

echo "Installing neccesary libraries..."
sudo apt install -y python3.8-distutils
sudo wget https://bootstrap.pypa.io/get-pip.py
python get-pip.py
python -m pip install flask
python -m pip install flask-mongoengine
python -m pip install passlib
python -m pip install gunicorn
sudo rm get-pip.py
echo "Successfully downloaded the libraries!"

echo "Starting the application..."
cd User-Login-System-Tutorial
mv /tmp/app.py .
python -m gunicorn -w 1 -b 10.0.0.2:5000 app:app --daemon