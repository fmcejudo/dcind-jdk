# Inspired by https://github.com/mumoshu/dcind
FROM alpine:3.4
MAINTAINER Toshiaki Maki <tmaki@pivotal.io>

ENV DOCKER_VERSION=1.12.1 \
    DOCKER_COMPOSE_VERSION=1.8

# Install Docker and Docker Compose
RUN apk --update --no-cache \
    add curl device-mapper py-pip iptables openjdk8 && \
    rm -rf /var/cache/apk/* && \
    curl https://get.docker.com/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz | tar zx && \
    mv /docker/* /bin/ && chmod +x /bin/docker* && \
    pip install docker-compose==${DOCKER_COMPOSE_VERSION}

# Install entrykit
RUN curl -L https://github.com/progrium/entrykit/releases/download/v0.4.0/entrykit_0.4.0_Linux_x86_64.tgz | tar zx && \
    chmod +x entrykit && \
    mv entrykit /bin/entrykit && \
    entrykit --symlink

# Maven

ARG MAVEN_VERSION=3.3.9
ARG USER_HOME_DIR="/root"

RUN mkdir -p /usr/share/maven /usr/share/maven/ref \
  && curl -fsSL http://apache.osuosl.org/maven/maven-3/$MAVEN_VERSION/binaries/apache-maven-$MAVEN_VERSION-bin.tar.gz \
    | tar -xzC /usr/share/maven \
  && ln -s /usr/share/maven/apache-maven-$MAVEN_VERSION/bin/mvn /usr/bin/mvn

ENV MAVEN_HOME /usr/share/maven/apache-maven-$MAVEN_VERSION
ENV MAVEN_CONFIG "$USER_HOME_DIR/.m2"
ENV JAVA_HOME=/usr/lib/jvm/java-1.8-openjdk

# Include useful functions to start/stop docker daemon in garden-runc containers in Concourse CI.
# Example: source /docker-lib.sh && start_docker
COPY docker-lib.sh /docker-lib.sh

ENTRYPOINT [ \
	"switch", \
		"shell=/bin/sh", "--", \
	"codep", \
		"/bin/docker daemon" \
]
