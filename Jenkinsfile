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
                sh 'ls -l node_modules/.bin'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
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
                // Optional: Push to prod if on master branch
                script {
                    if (env.BRANCH_NAME == 'master') {
                        sh 'docker tag dharsh177/devops-build:latest dharsh177/devops-prod:latest'
                        sh 'docker push dharsh177/devops-prod:latest'
                    }
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
