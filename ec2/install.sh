#!/bin/bash

curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash -
sudo yum update && sudo yum install -y nodejs npm git
sudo git clone https://github.com/andreich78-20/akvelon-cloud-aws.git akvelon-web-server && \
  cd akvelon-web-server/ec2/app && sudo npm install && \
  sudo npm install -g pm2 mysql && sudo pm2 start index.js && \
  sudo pm2 startup systemd && sudo pm2 save
