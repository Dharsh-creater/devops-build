pipeline {
    agent any

    environment {
        DOCKER_HUB_REPO_DEV = 'dharsh177/devops-pub'
        DOCKER_HUB_REPO_PROD = 'dharsh177/devops-pri'
    }

    stages {
        stage('Clone Repo') {
            steps {
                checkout scm
            }
        }

        stage('Install Dependencies') {
            steps {
                sh 'node -v'
                sh 'npm install'
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

        stage('Docker Build & Push') {
            when {
                branch 'dev'
            }
            steps {
                sh './build.sh'
            }
        }

        stage('Deploy to Server') {
            when {
                branch 'dev'
            }
            steps {
                sh './deploy.sh'
            }
        }

        stage('Build & Push Prod') {
            when {
                branch 'main'
            }
            steps {
                sh 'docker build -t devops-app:latest .'
                sh 'docker tag devops-app:latest $DOCKER_HUB_REPO_PROD:latest'
                sh 'docker push $DOCKER_HUB_REPO_PROD:latest'
                sh './deploy.sh'
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
    }
}

