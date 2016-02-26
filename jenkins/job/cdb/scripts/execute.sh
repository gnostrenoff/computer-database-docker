
docker pull gnostrenoff/jdk8-maven
docker images
docker create --name jdk8-maven gnostrenoff/jdk8-maven
docker cp . jdk8-maven:webapp
docker start -a jdk8-maven

