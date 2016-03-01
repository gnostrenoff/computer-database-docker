#!/bin/bash

set -x

# Detect if container exists
RUNNING_MYSQL=$(docker inspect --format="{{ .State.Running }}" "mysql-test" 2> /dev/null)

if [ $? -eq 1 ]; then
echo "creating mysql-test container"
 docker create --name mysql-test -e MYSQL_ROOT_PASSWORD=root gnostrenoff/mysql-test &
fi

docker start -a mysql-test &

# Detect if container exists
RUNNING_JDKMVN=$(docker inspect --format="{{ .State.Running }}" "jdk8-maven" 2> /dev/null)

# create container if it doesn't exist
if [ $? -eq 1 ]; then
echo "creating jdk8-maven container"
  docker create --name jdk8-maven --link mysql-test:localhost gnostrenoff/jdk8-maven
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
