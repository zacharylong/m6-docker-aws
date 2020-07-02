FROM ubuntu:latest

# Build instructions
ENV NAME="Zac"
RUN apt-get update -y && apt-get install python3 -y
RUN useradd -m zac

#RUN mkdir /app
COPY --chown=zac:zac app /app/
WORKDIR /app

USER zac



# Boot command
CMD [ "/usr/bin/python3", "hello.py" ]