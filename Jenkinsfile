pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-pass')
    }

    stages {
        stage('Clone') {
            steps {
                git branch: 'dev', url: 'https://github.com/Dharsh-creater/devops-build.git'
            }
        }

        stage('Docker Build') {
            steps {
                sh 'docker build -t dharsh177/devops-build:latest .'
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(credentialsId: 'dockerhub-pass', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                    sh 'echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin'
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

