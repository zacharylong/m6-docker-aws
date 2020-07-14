FROM ubuntu:latest

# Build instructions
ENV NAME="Zac"
ENV TZ=America/New_York
ENV DEBIAN_FRONTEND=noninteractive
RUN useradd -m -u 32676 ec2-user

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
RUN apt-get update -y && apt-get install emacs-nox apt-utils libpcre3 libpcre3-dev -y --no-install-recommends
RUN apt-get update -y && apt-get install python3 python3-pip tree git postgresql postgresql-contrib -y --no-install-recommends
RUN apt-get update -y && apt-get install postgresql-client postgresql-client-common libpq-dev build-essential python3-dev -y --no-install-recommends


# Create ec2-user account
#RUN useradd -m -u 90210 ec2-user
# Only create if doesn't already exist
#CMD ["id", "-u ec2-user >/dev/null 2>&1 || useradd ec2-user"]
RUN id -u ec2-user >/dev/null 2>&1 || useradd -m ec2-user

# install python packages
# USER ec2-user
# WORKDIR /home/ec2-user
# RUN pip3 install --user boto3 psycopg2-binary psycopg2 flask arrow


# get latest image-gallery from github
USER root
WORKDIR /home/ec2-user
COPY python-image-gallery-m6 /home/ec2-user/python-image-gallery-m6/
# RUN git clone https://github.com/zacharylong/python-image-gallery-m6.git
RUN chown -R ec2-user:ec2-user python-image-gallery-m6

# install latest requirements just in case!
# dont install as user, not on PATH
# USER ec2-user
WORKDIR /home/ec2-user/python-image-gallery-m6
# #RUN cd python-image-gallery-m6
RUN pip3 install -r requirements.txt --user

# Don't need nginx right?
# config nginx config files
# RUN cp /home/ec2-user/python-image-gallery-m6/nginx/nginx.conf /etc/nginx
# RUN cp /home/ec2-user/python-image-gallery-m6/nginx/default.d/image_gallery.conf /etc/nginx/default.d

#start/enable services
#RUN service nginx start
#CMD ["service", "nginx", "start"]
#RUN /etc/init.d/nginx start
#RUN service nginx enable

# RUN su ec2-user -l -c "cd ~/python-image-gallery && ./start" >/var/log/image_gallery.log 2>&1 &

# Set up Database, run shell script to create DB, insert data
# WORKDIR /app
#RUN ./createDB
# CMD ["./createDB"]

#Run the uwsgi server and serve the app
USER ec2-user
WORKDIR /home/ec2-user/python-image-gallery-m6/gallery/ui
ENV FLASK_APP=app.py
ENV FLASK_ENV=development
EXPOSE 5555
EXPOSE 9191
EXPOSE 8888
#CMD ["uwsgi", "--http", "8888", "--module", "gallery.ui.app:app"]
#CMD ["flask", "run", "--host", "0.0.0.0"]
CMD ["uwsgi", "--http", "5555", "--module", "app:app"]
#CMD ["uwsgi", "--http", ":5555", "--module", "app:app", "--master", "--processes", "4", "--threads", "2", "--stats", "0.0.0.0:9191"]
#copy of start script
#CMD ["uwsgi", "-s", "localhost:5555", "--manage-script-name", "--mount", "/=gallery.ui.app:app"]

# Boot command (same as above)
# CMD [ "/python-image-gallery-m6", "./start" ]

# Users example, created developer user and run as him
# USER developer
# CMD ["/bin/bash"]