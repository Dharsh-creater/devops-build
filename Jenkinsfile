pipeline {
    agent any

    environment {
        DOCKER_HUB_CREDENTIALS = credentials('dockerhub-pass')
    }

    stages {
        stage('Checkout SCM') {
            steps {
                git branch: 'dev', url: 'https://github.com/Dharsh-creater/devops-build.git'
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
<<<<<<< HEAD
                sh 'chmod -R 755 node_modules/.bin'      // <-- fixes permission denied
                sh 'ls -l node_modules/.bin'             // optional: debug list permissions
=======
                sh 'chmod -R 755 node_modules/.bin'       // fix permissions
                sh 'ls -l node_modules/.bin'              // show permissions (for debug)
>>>>>>> c55fed3a34a6c63beaec023dca49b953b518bb87
            }
        }

        stage('Build React App') {
            steps {
                sh 'npm run build'
            }
        }

<<<<<<< HEAD
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
=======
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
>>>>>>> c55fed3a34a6c63beaec023dca49b953b518bb87
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
        success {
            echo 'Build succeeded!'
        }
    }
}

