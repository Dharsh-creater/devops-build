pipeline {
    agent any
    
    environment {
        DOCKER_USERNAME = 'dharsh177'
        DEV_REPO = 'devops-react-app-dev'
        PROD_REPO = 'devops-react-app-prod'
        GITHUB_REPO = 'Dharsh-creater/devops-build'
    }
    
    stages {
        stage('Checkout') {
            steps {
                checkout scm
                echo "Checked out code from ${env.BRANCH_NAME}"
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    def imageTag = env.BRANCH_NAME == 'master' ? 'latest' : env.BRANCH_NAME
                    def repoName = env.BRANCH_NAME == 'master' ? env.PROD_REPO : env.DEV_REPO
                    def fullImageName = "${env.DOCKER_USERNAME}/${repoName}:${imageTag}"
                    
                    echo "Building Docker image: ${fullImageName}"
                    
                    // Build the Docker image
                    sh "docker build -t ${fullImageName} ."
                    
                    // Store image name for later stages
                    env.DOCKER_IMAGE = fullImageName
                    env.REPO_NAME = repoName
                    env.IMAGE_TAG = imageTag
                }
            }
        }
        
        stage('Push to Docker Hub') {
            steps {
                script {
                    echo "Pushing image to Docker Hub: ${env.DOCKER_IMAGE}"
                    
                    // Login to Docker Hub (credentials should be configured in Jenkins)
                    withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        sh "echo ${env.DOCKER_PASS} | docker login -u ${env.DOCKER_USER} --password-stdin"
                        
                        // Push the image
                        sh "docker push ${env.DOCKER_IMAGE}"
                        
                        // Logout from Docker Hub
                        sh "docker logout"
                    }
                }
            }
        }
        
        stage('Deploy to Environment') {
            steps {
                script {
                    if (env.BRANCH_NAME == 'master') {
                        echo "Deploying to PRODUCTION environment"
                        // Production deployment logic
                        sh """
                            # Stop existing production container
                            docker stop devops-react-app-prod || true
                            docker rm devops-react-app-prod || true
                            
                            # Start new production container
                            docker run -d \\
                                --name devops-react-app-prod \\
                                --restart unless-stopped \\
                                -p 3000:80 \\
                                -e NODE_ENV=production \\
                                ${env.DOCKER_IMAGE}
                        """
                    } else {
                        echo "Deploying to DEVELOPMENT environment"
                        // Development deployment logic
                        sh """
                            # Stop existing development container
                            docker stop devops-react-app-dev || true
                            docker rm devops-react-app-dev || true
                            
                            # Start new development container
                            docker run -d \\
                                --name devops-react-app-dev \\
                                --restart unless-stopped \\
                                -p 3001:80 \\
                                -e NODE_ENV=development \\
                                ${env.DOCKER_IMAGE}
                        """
                    }
                }
            }
        }
        
        stage('Health Check') {
            steps {
                script {
                    def port = env.BRANCH_NAME == 'master' ? '3000' : '3001'
                    def containerName = env.BRANCH_NAME == 'master' ? 'devops-react-app-prod' : 'devops-react-app-dev'
                    
                    echo "Performing health check on port ${port}"
                    
                    // Wait for container to start
                    sleep 30
                    
                    // Health check
                    sh """
                        # Check if container is running
                        if docker ps | grep -q ${containerName}; then
                            echo "Container ${containerName} is running"
                            
                            # Health check endpoint
                            if curl -f http://localhost:${port}/health; then
                                echo "Health check passed for ${containerName}"
                            else
                                echo "Health check failed for ${containerName}"
                                exit 1
                            fi
                        else
                            echo "Container ${containerName} is not running"
                            exit 1
                        fi
                    """
                }
            }
        }
    }
    
    post {
        always {
            // Clean up workspace
            cleanWs()
        }
        success {
            script {
                def environment = env.BRANCH_NAME == 'master' ? 'PRODUCTION' : 'DEVELOPMENT'
                echo "Pipeline completed successfully for ${environment} environment"
                echo "Image: ${env.DOCKER_IMAGE}"
                echo "Application URL: http://localhost:${env.BRANCH_NAME == 'master' ? '3000' : '3001'}"
            }
        }
        failure {
            script {
                def environment = env.BRANCH_NAME == 'master' ? 'PRODUCTION' : 'DEVELOPMENT'
                echo "Pipeline failed for ${environment} environment"
            }
        }
    }
} 