#!/usr/bin/bash

# Manual set up behind the scenes:
# Create RDS instance from previous snapshot m6-demo-db
# Make RDS publiclly accessible, in defauly VPC (same as EC2), and Open Security Group
# Create S3 buckets:
#   zacs-m6-image-gallery
#   zacs-m6-image-gallery-config
# Create secrets manager for M6:
#   image_gallery_secret-m6
#   {
#      "username": "image_gallery",
#      "password": "n,|gRz$#_Bc&EmAjyI)t[j3vCv^4ty4n",
#      "engine": "postgres",
#      "host": "m6-demo-db.ccywtilknp5x.us-east-2.rds.amazonaws.com",
#      "port": 5432,
#      "dbInstanceIdentifier": "m6-demo-db",
#      "database_name": "image_gallery"
#    }
# Give this EC2 role IAM access for now upon boot
# store IAM secret keys in Secret manager so that app can pull them down for access to buckets
# add endpoint to secrets manager to default vpc by creating security group and putting default vpc in sg
# assign endpoint security group to EC2 and VPC!
# 

# Install packages
yum -y update
yum install -y emacs-nox nano tree python3 git postgresql postgresql-devel gcc python3-devel
amazon-linux-extras install -y nginx1
pip3 install --user boto3 psycopg2 flask uwsgi arrow


# Configure/install custom software
# Deploy python image gallery
cd /home/ec2-user
git clone https://github.com/zacharylong/python-image-gallery-m6.git
chown -R ec2-user:ec2-user python-image-gallery-m6
su ec2-user -l -c "cd ~/python-image-gallery-m6 && pip3 install -r requirements.txt --user"

BUCKET="zacs-m6-image-gallery-config"
CONFIG_BUCKET="zacs-m6-image-gallery-config"

#copy script files into S3
cd /home/ec2-user/python-image-gallery-m6

aws s3 cp ec2-scripts/ec2-prod-1.1.sh s3://${BUCKET}
aws s3 cp ec2-scripts/ec2-prod-latest.sh s3://${BUCKET}
aws s3 sync nginx s3://${BUCKET}/nginx

#configure nginx
aws s3 cp s3://${CONFIG_BUCKET}/nginx/nginx.conf /etc/nginx
aws s3 cp s3://${CONFIG_BUCKET}/nginx/default.d/image_gallery.conf /etc/nginx/default.d
aws s3 cp s3://${CONFIG_BUCKET}/nginx/index.html /usr/share/nginx/html
chown nginx:nginx /usr/share/nginx/html/index.html

# Start/enable services
systemctl stop postfix
systemctl disable postfix
systemctl start nginx
systemctl enable nginx

#configure docker for aws
cd /home/ec2-user
amazon-linux-extras install docker
service docker start
usermod -a -G docker ec2-user

#need to logout here to pick up groups?

#auto-start nginx server in background
# su ec2-user -l -c "cd ~/python-image-gallery && ./start" >/var/log/image_gallery.log 2>&1 &

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

