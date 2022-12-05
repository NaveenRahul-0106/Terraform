#!/bin/bash
# yum -y install httpd
# systemctl enable httpd
# echo '<html><h1>Hello From Your First Lab Web Server!</h1></html>' > /var/www/html/index.html
# sudo systemctl start httpd


sudo apt-get remove docker docker-engine docker.io containerd runc

sudo apt-get update
sudo apt-get install \
    ca-certificates \
    curl \
    gnupg \
    lsb-release