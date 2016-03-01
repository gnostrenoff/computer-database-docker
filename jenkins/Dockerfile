FROM  jenkins:latest

ENV DEBIAN_FRONTEND noninteractive

USER root
 
RUN curl -sSL https://get.docker.com/ | sh \
    && rm -rf /var/lib/apt/lists/*

ENV DOCKER_HOST tcp://dind:4242
 
COPY plugins.txt /usr/share/jenkins/plugins.txt
RUN /usr/local/bin/plugins.sh /usr/share/jenkins/plugins.txt

COPY /cdb-webapp/cdb-job /var/jenkins_home/jobs/cdb-webapp
COPY /cdb-webapp/cdb-config /opt/cdb-config
