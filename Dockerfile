# Inspired by https://github.com/mumoshu/dcind
FROM maven:3.6.0-jdk-12-alpine 
MAINTAINER Francisco Miguel Cejudo <fmcejudo@gmail.com>

ENV DOCKER_VERSION=1.11.1 \
    DOCKER_COMPOSE_VERSION=1.7.1 \
    M2_HOME=~/.m2 \
    M2_LOCAL_REPO=~/.m2

RUN mkdir -p ${M2_HOME} && mkdir -p "${M2_LOCAL_REPO}/repository"

# Install Docker, Docker Compose
RUN apk --update --no-cache \
        add curl device-mapper mkinitfs zsh e2fsprogs e2fsprogs-extra iptables && \
        curl https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz | tar zx && \
        mv /docker/* /bin/ && chmod +x /bin/docker* \
    && \
        apk add py-pip && \
        pip install docker-compose==${DOCKER_COMPOSE_VERSION}

COPY ./entrykit /bin/entrykit

RUN chmod +x /bin/entrykit && entrykit --symlink

COPY settings.xml ${M2_HOME}/settings.xml

# Include useful functions to start/stop docker daemon in garden-runc containers on Concourse CI
# Its usage would be something like: source /docker.lib.sh && start_docker "" "" "-g=$(pwd)/graph"
COPY docker-lib.sh /docker-lib.sh

ENTRYPOINT ["entrykit", "-e"]