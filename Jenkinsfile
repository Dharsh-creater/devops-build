pipeline {
    agent any

    stages {
        stage('Clone Repo') {
            steps {
                git 'https://github.com/Dharsh-creater/devops-build.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                dir('my-app') {
                    sh 'npm install'
                }
            }
        }

        stage('Build React App') {
            steps {
                dir('my-app') {
                    sh 'npm run build'
                }
            }
        }

        stage('Docker Build & Push') {
            steps {
                sh 'docker build -t dharsh177/devops-app:latest .'
                withCredentials([string(credentialsId: 'dockerhub-token', variable: 'DOCKER_PASSWORD')]) {
                    sh 'echo $DOCKER_PASSWORD | docker login -u dharsh177 --password-stdin'
                    sh 'docker push dharsh177/devops-app:latest'
                }
            }
        }
    }
}
