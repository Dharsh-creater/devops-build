#!/bin/bash
docker rm -f devops-build
docker run --name devops-build -p 80:80 -d devops-build-app
