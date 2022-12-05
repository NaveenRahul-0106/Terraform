#!/bin/bash

sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

sudo mkdir -p /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg

sudo echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

sudo apt-get update
sudo apt install -y docker.io
sudo apt-get update

sudo apt install -y python3
sudo apt install -y python3-pip
sudo git clone https://github.com/tonbara-stephanie/simple-webapp-flask.git
sudo cd simple-webapp-flask
sudo pip install -r requirements.txt
sudo python3 app.py



