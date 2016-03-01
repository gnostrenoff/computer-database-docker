docker-compose stop
echo "removing containers ..."
docker rm jenkins_ctn
docker rm dind_ctn
echo "done"
