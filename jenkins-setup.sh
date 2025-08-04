#!/bin/bash

# Jenkins Setup Script
# This script helps configure Jenkins for the DevOps pipeline

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging function
log() {
    echo -e "${BLUE}[$(date +'%Y-%m-%d %H:%M:%S')]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1" >&2
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Function to check if Jenkins is running
check_jenkins() {
    if curl -s http://localhost:8080 > /dev/null 2>&1; then
        return 0
    else
        return 1
    fi
}

# Function to wait for Jenkins to be ready
wait_for_jenkins() {
    log "Waiting for Jenkins to be ready..."
    
    local max_attempts=30
    local attempt=1
    
    while [ $attempt -le $max_attempts ]; do
        if check_jenkins; then
            success "Jenkins is ready!"
            return 0
        fi
        
        log "Attempt $attempt/$max_attempts - Jenkins not ready yet..."
        sleep 10
        ((attempt++))
    done
    
    error "Jenkins failed to start within expected time"
    return 1
}

# Function to get Jenkins initial admin password
get_jenkins_password() {
    local jenkins_home="$HOME/.jenkins"
    local password_file="$jenkins_home/secrets/initialAdminPassword"
    
    if [ -f "$password_file" ]; then
        cat "$password_file"
    else
        error "Could not find Jenkins initial admin password"
        return 1
    fi
}

# Function to install Jenkins plugins
install_plugins() {
    log "Installing required Jenkins plugins..."
    
    # List of required plugins
    local plugins=(
        "git"
        "docker-plugin"
        "docker-workflow"
        "pipeline"
        "credentials"
        "ssh-credentials"
        "plain-credentials"
        "workflow-aggregator"
        "blueocean"
        "github"
        "github-branch-source"
        "multibranch-scan-webhook-trigger"
    )
    
    for plugin in "${plugins[@]}"; do
        log "Installing plugin: $plugin"
        # This would typically be done through Jenkins CLI or REST API
        # For now, we'll just log the plugins that need to be installed
    done
    
    success "Plugin installation instructions logged"
}

# Function to create Jenkins jobs
create_jenkins_jobs() {
    log "Creating Jenkins jobs..."
    
    # This would create the multibranch pipeline job
    # For now, we'll provide instructions
    echo "Jobs to be created manually in Jenkins:"
    echo "1. Create a new 'Multibranch Pipeline' job"
    echo "2. Name it 'devops-react-app'"
    echo "3. Configure Git repository: https://github.com/Dharsh-creater/devops-build"
    echo "4. Set branch sources to include 'dev' and 'master'"
    echo "5. Set Jenkinsfile path to 'Jenkinsfile'"
    echo "6. Configure webhook triggers"
}

# Function to configure Docker Hub credentials
configure_credentials() {
    log "Configuring Docker Hub credentials..."
    
    echo "In Jenkins, go to:"
    echo "1. Manage Jenkins > Manage Credentials"
    echo "2. Add Credentials > Username with password"
    echo "3. ID: docker-hub-credentials"
    echo "4. Username: your-docker-hub-username"
    echo "5. Password: your-docker-hub-access-token"
    echo "6. Description: Docker Hub Credentials"
}

# Function to configure webhooks
configure_webhooks() {
    log "Configuring GitHub webhooks..."
    
    echo "In your GitHub repository:"
    echo "1. Go to Settings > Webhooks"
    echo "2. Add webhook"
    echo "3. Payload URL: http://your-jenkins-url/github-webhook/"
    echo "4. Content type: application/json"
    echo "5. Events: Just the push event"
    echo "6. Active: Yes"
}

# Main execution
main() {
    log "Starting Jenkins setup..."
    
    # Check if Jenkins is running
    if ! check_jenkins; then
        error "Jenkins is not running. Please start Jenkins first."
        echo "Run: java -jar jenkins.war --httpPort=8080"
        exit 1
    fi
    
    success "Jenkins is running"
    
    # Wait for Jenkins to be ready
    if ! wait_for_jenkins; then
        exit 1
    fi
    
    # Get initial admin password
    log "Jenkins initial admin password:"
    if get_jenkins_password; then
        echo "Use this password to complete Jenkins setup"
    fi
    
    echo
    log "Next steps:"
    echo "1. Open http://localhost:8080 in your browser"
    echo "2. Complete the Jenkins setup wizard"
    echo "3. Install suggested plugins"
    echo "4. Create admin user"
    echo "5. Run this script again to configure the pipeline"
    
    echo
    log "After initial setup, run:"
    echo "  ./jenkins-setup.sh --configure"
}

# Handle script arguments
case "${1:-}" in
    --configure)
        log "Configuring Jenkins pipeline..."
        install_plugins
        create_jenkins_jobs
        configure_credentials
        configure_webhooks
        success "Jenkins configuration instructions provided"
        ;;
    -h|--help)
        echo "Usage: $0 [--configure]"
        echo "  --configure: Configure Jenkins pipeline after initial setup"
        exit 0
        ;;
    *)
        main
        ;;
esac 