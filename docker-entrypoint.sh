#!/bin/sh
wget -O docker.tgz "https://download.docker.com/linux/static/stable/x86_64/docker-18.09.4.tgz" && \
   tar --extract \
    --file docker.tgz \
    --strip-components 1 \
    --directory /usr/local/bin/ \
  ; \
  rm docker.tgz; \
  \
  dockerd --version; \
  docker --version

groupadd docker
usermod -aG docker $(whoami)

dockerd --host=unix:///var/run/docker.sock --host=tcp://0.0.0.0:2375 
