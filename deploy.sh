#!/bin/bash
docker-compose down
<<<<<<< HEAD
docker-compose up -d --build
=======
docker-compose up -d

docker run -d -p 80:80 --name react-prod dharsh177/devops-dev:latest

>>>>>>> c55fed3a34a6c63beaec023dca49b953b518bb87
