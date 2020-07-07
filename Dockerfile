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

#Environment variables from M6 Requirements:
USER root
ENV PG_HOST="m6-demo-db.ccywtilknp5x.us-east-2.rds.amazonaws.com"
ENV PG_PORT=5432
ENV IG_DATABASE="image_gallery"
ENV IG_USER="image_gallery"
ENV IG_PASSWD="n,|gRz$#_Bc&EmAjyI)t[j3vCv^4ty4n"
ENV IG_PASSWD_FILE="IG_PASSWRD" 
ENV S3_IMAGE_BUCKET="zacs-m6-image-gallery"

# install basic packages
USER root
RUN apt-get update -y && apt-get install nginx emacs-nox apt-utils libpcre3 libpcre3-dev -y --no-install-recommends
RUN apt-get install python3 python3-pip tree git postgresql postgresql-contrib -y --no-install-recommends
RUN apt-get install postgresql-client postgresql-client-common libpq-dev build-essential python3-dev -y --no-install-recommends

# install python packages
RUN pip3 install --user boto3 psycopg2-binary psycopg2 flask uwsgi arrow

# Create ec2-user account
#RUN useradd -m -u 90210 ec2-user
# Only create if doesn't already exist
RUN id -u ec2-user >/dev/null 2>&1 || useradd ec2-user

# get latest image-gallery from github
RUN git clone https://github.com/zacharylong/python-image-gallery-m6.git
RUN chown -R ec2-user:ec2-user python-image-gallery-m6

# install latest requirements just in case!
#USER ec2-user
WORKDIR /python-image-gallery-m6
#RUN cd python-image-gallery-m6
RUN pip3 install -r requirements.txt --user

# config nginx config files
RUN cp /python-image-gallery-m6/nginx/nginx.conf /etc/nginx
RUN cp /python-image-gallery-m6/nginx/default.d/image_gallery.conf /etc/nginx/default.d

#start/enable services
#RUN service nginx start
#CMD ["service", "nginx", "start"]
#RUN /etc/init.d/nginx start
#RUN service nginx enable

# RUN su ec2-user -l -c "cd ~/python-image-gallery && ./start" >/var/log/image_gallery.log 2>&1 &

# Set up Database, run shell script to create DB, insert data
WORKDIR /app
#RUN ./createDB
CMD ["./createDB"]

#Run the uwsgi server and serve the app
USER ec2-user
WORKDIR /python-image-gallery-m6
ENV FLASK_APP=gallery.ui.app.py
ENV FLASK_ENV=development
EXPOSE 5555
EXPOSE 9191
CMD ["uwsgi", "--http", ":5555", "--module", "gallery.ui.app:app", "--master", "--processes", "4", "--threads", "2", "--stats", "0.0.0.0:9191"]

# Boot command (same as above)
CMD [ "/python-image-gallery-m6", "./start" ]

# Users example, created developer user and run as him
# USER developer
# CMD ["/bin/bash"]