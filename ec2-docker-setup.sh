#!/usr/bin/bash

# Install packages
yum -y update
yum install -y emacs-nox nano tree python3 git postgresql postgresql-devel gcc python3-devel
pip3 install --user boto3 psycopg2 flask uwsgi 

# Configure/install custom software
# Deploy python image gallery
cd /home/ec2-user
git clone https://github.com/zacharylong/python-image-gallery.git
chown -R ec2-user:ec2-user python-image-gallery
su ec2-user -c "cd ~/python-image-gallery && pip3 install -r requirements.txt --user"

# Start/enable services
systemctl stop postfix
systemctl disable postfix

#configure docker for aws
cd /home/ec2-user
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user

#need to logout here to pick up groups?


#m6 docker
git clone https://github.com/zacharylong/m6-docker-aws.git
cd /home/ec2-user/m6-docker-aws

#build the test ubuntu image
docker build -f Dockerfile . -t ubuntu:latest

#Build the flask docker image
docker build -f Dockerfile.flask . -t flask:latest

#create volume for database
docker volume create data
docker run --volume data:/mnt/data ubuntu

