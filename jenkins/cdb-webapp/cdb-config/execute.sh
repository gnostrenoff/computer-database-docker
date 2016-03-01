#!/bin/bash

if [ -e $(docker ps -aq -f "name=mysql-test") ]
then
echo "creating mysql-test container"
 docker create --name mysql-test -e MYSQL_ROOT_PASSWORD=root gnostrenoff/mysql-test &
fi

docker start mysql-test

sleep 8

# create container if it doesn't exist
if [ -e $(docker ps -aq -f "name=jdk8-maven") ]
then
echo "creating jdk8-maven container"
  docker create --name jdk8-maven --link mysql-test:localhost -w /cdb maven:3.3.3-jdk-8 mvn clean package
fi

# copy jenkins workspace into jdk maven container, then start it 
echo "copy jenkins workspace into jdk maven container, then start it"
docker cp . jdk8-maven:cdb
docker start -a jdk8-maven
docker stop mysql-test

# built webapp and push it
echo "copy war from jdk8-maven:cdb/target/computer-database.war to cdb-webapp.war"
docker cp jdk8-maven:cdb/target/computer-database.war cdb-webapp.war
echo "build webapp image"
docker build -t gnostrenoff/cdb-webapp -f cdb-config/Dockerfile .
echo "push webapp image"
docker push gnostrenoff/cdb-webapp

bash cdb-config/glazer-deploy.sh --host 192.168.10.225 --port 65000 --env MYSQL_ROOT_PASSWORD=root gnostrenoff-cdb-mysql-prod gnostrenoff/mysql-prod
bash cdb-config/glazer-deploy.sh --host 192.168.10.225 --port 65000 --link gnostrenoff-cdb-mysql-prod:localhost --publish 65166:8080 gnostrenoff-cdb-webapp gnostrenoff/cdb-webapp
