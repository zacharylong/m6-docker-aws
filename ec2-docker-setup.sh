#!/usr/bin/bash

# Install packages
yum -y update
amazon-linux-extras install -y java-openjdk11
yum install -y java-11-openjdk-devel
yum install -y emacs-nox nano tree python3 git postgresql postgresql-devel gcc python3-devel
pip3 install --user boto3 psycopg2 flask uwsgi 

# Configure/install custom software
cd /home/ec2-user
git clone https://github.com/zacharylong/python-image-gallery.git
chown -R ec2-user:ec2-user python-image-gallery
su ec2-user -c "cd ~/python-image-gallery && pip3 install -r requirements.txt --user"

# Start/enable services
systemctl stop postfix
systemctl disable postfix

#configure docker
cd /home/ec2-user
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user
git clone https://github.com/zacharylong/m6-docker-aws.git
cd m6-docker-aws
docker build -f Dockerfile . -t ubuntu:latest
docker build -f Dockerfile.flask . -t flask:latest
docker volume create data
docker run --volume data:/mnt/data ubuntu