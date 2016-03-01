
docker-compose up -d

echo -n "password : "
read -s password

docker exec jenkins_ctn docker login --username="gnostrenoff" --email="gnostrenoff@excilys.com" --password="$password"
