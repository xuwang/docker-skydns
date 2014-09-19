#!/bin/bash
docker build -t skybuild .
docker run --rm  -v /var/run/docker.sock:/var/run/docker.sock skybuild:latest

# To clean up, uncomment the line below
#docker rmi skybuild:latest

docker images