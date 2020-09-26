#!/bin/bash

sudo -E bash -
sudo yum update -y && sudo yum install -y git
git clone https://github.com/andreich78-20/akvelon-cloud-aws.git akvelon-db
sudo wget https://dev.mysql.com/get/mysql57-community-release-el7-11.noarch.rpm && \
sudo yum localinstall -y mysql57-community-release-el7-11.noarch.rpm && \
sudo yum install -y mysql-community-server && \
sudo chkconfig mysqld on && \
sudo service mysqld start
