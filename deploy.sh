#!/bin/bash
docker-compose down
docker-compose up -d

docker run -d -p 80:80 --name react-prod dharsh177/devops-dev:latest

