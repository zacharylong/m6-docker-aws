# Create postgres
# create users
# create tables
# copy app from github
# set up app
# launch app

FROM ubuntu:latest

# Build instructions
ENV NAME="Zac"
ENV TZ=America/New_York
ENV DEBIAN_FRONTEND=noninteractive

# install basic packages
RUN apt-get update -y && apt-get install nginx emacs-nox apt-utils python3 python3-pip tree git postgresql postgresql-contrib postgresql-client postgresql-client-common libpq-dev build-essential python3-dev -y --no-install-recommends
# install python packages
RUN pip3 install --user boto3 psycopg2-binary psycopg2 flask uwsgi arrow

RUN useradd -m -u 90210 ec2-user

# get latest image-gallery from github
RUN git clone https://github.com/zacharylong/python-image-gallery-m6.git
RUN chown -R ec2-user:ec2-user python-image-gallery-m6

# install latest requirements just in case!
USER ec2-user
RUN cd /python-image-gallery-m6
RUN pip3 install -r requirements.txt --user

# config nginx config files
RUN cp /python-image-gallery-m6/nginx/nginx.conf /etc/nginx
RUN cp /python-image-gallery-m6/nginx/default.d/image_gallery.conf /etc/nginx/default.d

#start/enable services
RUN service nginx start
RUN /etc/init.d/nginx start
RUN service nginx enable

# RUN su ec2-user -l -c "cd ~/python-image-gallery && ./start" >/var/log/image_gallery.log 2>&1 &


USER ec2-user

# Boot command
#CMD [ "/python-image-gallery-m6", "./start" ]

# Users example, created developer user and run as him
# USER developer
# CMD ["/bin/bash"]