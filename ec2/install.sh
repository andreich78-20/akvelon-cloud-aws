#!/bin/bash

curl -sL https://rpm.nodesource.com/setup_14.x | sudo -E bash -
yum update && yum install -y nodejs npm git
git clone https://github.com/andreich78-20/akvelon-cloud-aws.git akvelon-web-server
cd akvelon-web-server/ec2/app
npm install
npm install -y mysql
npm install -g pm2
pm2 start index.js
pm2 startup systemd
pm2 save
