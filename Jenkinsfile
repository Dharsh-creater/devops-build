pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-pass')
    }

    stages {
        stage('Clone Repo') {
            steps {
                git branch: 'dev', url: 'https://github.com/Dharsh-creater/devops-build.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'rm -rf node_modules package-lock.json'
                sh 'npm install'
                sh 'chmod -R 755 node_modules/.bin'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Docker Build & Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
                    sh 'docker build -t dharsh177/devops-build:latest .'
                    sh 'docker tag dharsh177/devops-build:latest dharsh177/devops-pub:latest'
                    sh 'docker push dharsh177/devops-pub:latest'
                }
            }
        }
    }

    post {
        always {
            echo "Build finished!"
        }
        failure {
            echo "Build failed!"
        }
    }
}

