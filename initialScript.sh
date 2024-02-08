#! /bin/bash

sudo apt update -y && sudo apt install docker.io -y
sudo usermod -aG docker ubuntu
#docker run -p 8080:80 nginx

sudo curl -fsSL https://github.com/docker/compose/releases/download/v2.15.0/docker-compose-linux-x86_64  -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose