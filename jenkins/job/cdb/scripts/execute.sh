CONTAINER="jdk8mvn"

# Detect if container is running
RUNNING=$(docker inspect --format="{{ .State.Running }}" $CONTAINER 2> /dev/null)

if [ $? -eq 1 ]; then
  docker pull gnostrenoff/jdk8-maven
  docker create --name jdk8-maven gnostrenoff/jdk8-maven
fi

docker cp . jdk8-maven:webapp
docker start -a jdk8-maven

