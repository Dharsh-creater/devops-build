#!/bin/bash

# Docker Hub pull script
# Usage: ./pull-from-dockerhub.sh [environment] [version]

set -e  # Exit on any error

# Configuration
DOCKER_USERNAME="dharsh177"
DEV_REPO="devops-react-app-dev"
PROD_REPO="devops-react-app-prod"
DEFAULT_VERSION="latest"

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

# Function to check if Docker is running
check_docker() {
    if ! docker info > /dev/null 2>&1; then
        error "Docker is not running. Please start Docker and try again."
        exit 1
    fi
    log "Docker is running"
}

# Function to pull image from Docker Hub
pull_image() {
    local repo=$1
    local version=$2
    local image_name="${DOCKER_USERNAME}/${repo}:${version}"
    
    log "Pulling image from Docker Hub: ${image_name}"
    
    # Pull the image
    docker pull "${image_name}"
    
    success "Image pulled successfully: ${image_name}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [environment] [version]"
    echo "  environment: dev or prod (default: dev)"
    echo "  version:     Version tag for the Docker image (default: ${DEFAULT_VERSION})"
    echo
    echo "Examples:"
    echo "  $0                    # Pull dev:latest"
    echo "  $0 prod              # Pull prod:latest"
    echo "  $0 dev v1.0.0        # Pull dev:v1.0.0"
    echo "  $0 prod 2024-01-15   # Pull prod:2024-01-15"
    echo
    echo "Available repositories:"
    echo "  - ${DOCKER_USERNAME}/${DEV_REPO} (public)"
    echo "  - ${DOCKER_USERNAME}/${PROD_REPO} (private)"
}

# Main execution
main() {
    # Parse arguments
    ENVIRONMENT=${1:-"dev"}
    VERSION=${2:-$DEFAULT_VERSION}
    
    # Validate environment
    if [[ "$ENVIRONMENT" != "dev" && "$ENVIRONMENT" != "prod" ]]; then
        error "Invalid environment: $ENVIRONMENT. Use 'dev' or 'prod'."
        exit 1
    fi
    
    log "Starting Docker Hub pull process..."
    log "Environment: ${ENVIRONMENT}"
    log "Version: ${VERSION}"
    log "Docker Hub username: ${DOCKER_USERNAME}"
    
    # Pre-flight checks
    check_docker
    
    # Determine repository based on environment
    if [[ "$ENVIRONMENT" == "dev" ]]; then
        REPO="${DEV_REPO}"
    else
        REPO="${PROD_REPO}"
    fi
    
    # Pull the image
    pull_image "${REPO}" "${VERSION}"
    
    # Display final information
    echo
    success "Docker Hub pull completed successfully!"
    log "Image: ${DOCKER_USERNAME}/${REPO}:${VERSION}"
    echo
    log "You can now run the container using:"
    log "  docker run -p 3000:80 ${DOCKER_USERNAME}/${REPO}:${VERSION}"
}

# Handle script arguments
case "${1:-}" in
    -h|--help)
        show_usage
        exit 0
        ;;
esac

# Run main function
main "$@" 