pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-pass')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                checkout scm
            }
        }

        stage('Clone Repo') {
            steps {
                git branch: 'dev', url: 'https://github.com/Dharsh-creater/devops-build.git'
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'rm -rf node_modules package-lock.json'
                sh 'npm install'
                sh 'chmod -R 755 node_modules/.bin'       // fix permissions
                sh 'ls -l node_modules/.bin'              // show permissions (for debug)
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Docker Build & Push') {
            steps {
                script {
                    dockerImage = docker.build("dharsh-creator/devops-build:dev")
                    docker.withRegistry('', DOCKER_HUB_CREDENTIALS) {
                        dockerImage.push()
                    }
                }
            }
        }

        stage('Deploy to Server') {
            steps {
                echo 'Deploying to server...'
                // your deploy commands here
            }
        }

        stage('Build & Push Prod') {
            steps {
                script {
                    dockerImageProd = docker.build("dharsh-creator/devops-build:prod")
                    docker.withRegistry('', DOCKER_HUB_CREDENTIALS) {
                        dockerImageProd.push()
                    }
                }
            }
        }
    }

    post {
        always {
            echo 'Build finished!'
        }
        failure {
            echo 'Build failed!'
        }
        success {
            echo 'Build succeeded!'
        }
    }
}

