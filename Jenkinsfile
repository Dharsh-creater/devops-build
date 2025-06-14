pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'docker177/devops-prod'
        DOCKER_HUB_USERNAME = 'docker177'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/Dharsh-creater/devops-build.git', branch: 'main'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'npm install'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        docker build -t $DOCKER_HUB_REPO:latest .
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_HUB_REPO:latest
                    '''
                }
            }
        }
    }
}

