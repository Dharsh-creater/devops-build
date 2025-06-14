pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO = 'dharsh177/devops-prod'
        DOCKER_HUB_USERNAME = 'dharsh177'
    }

    stages {
        stage('Clone Repo') {
            steps {
                git url: 'https://github.com/Dharsh-creater/devops-build.git', branch: 'main'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'cd my-app && npm install'
            }
        }

        stage('Build React App') {
            steps {
                sh 'cd my-app && npm run build'
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'github-creds', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh '''
                        docker build -t dharsh177/devops-prod:latest .
                        echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                        docker push $DOCKER_HUB_REPO:latest
                    '''
                }
            }
        }
    }
}

