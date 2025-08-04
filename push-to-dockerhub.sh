#!/bin/bash

# Docker Hub push script
# Usage: ./push-to-dockerhub.sh [version]

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

# Function to check if logged in to Docker Hub
check_docker_login() {
    # Try to get username from docker info
    local username=$(docker info 2>/dev/null | grep -i "username" | head -1 | cut -d: -f2 | tr -d ' ')
    
    if [ -z "$username" ]; then
        warning "Could not detect Docker Hub login status."
        warning "Please ensure you're logged in with: docker login"
        warning "Continuing anyway..."
    else
        log "Logged in to Docker Hub as: $username"
    fi
}

# Function to build image
build_image() {
    local repo=$1
    local version=$2
    local image_name="${DOCKER_USERNAME}/${repo}:${version}"
    
    log "Building image: ${image_name}"
    
    # Build the image
    docker build -t "${image_name}" .
    
    success "Image built successfully: ${image_name}"
}

# Function to push image to Docker Hub
push_image() {
    local repo=$1
    local version=$2
    local image_name="${DOCKER_USERNAME}/${repo}:${version}"
    
    log "Pushing image to Docker Hub: ${image_name}"
    
    # Push the image
    docker push "${image_name}"
    
    success "Image pushed successfully: ${image_name}"
}

# Function to tag and push to both repositories
push_to_both_repos() {
    local version=$1
    
    log "Building and pushing to both dev and prod repositories..."
    
    # Build and push to dev repository
    log "=== DEV REPOSITORY ==="
    build_image "${DEV_REPO}" "${version}"
    push_image "${DEV_REPO}" "${version}"
    
    # Build and push to prod repository
    log "=== PROD REPOSITORY ==="
    build_image "${PROD_REPO}" "${version}"
    push_image "${PROD_REPO}" "${version}"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [version]"
    echo "  version: Version tag for the Docker image (default: ${DEFAULT_VERSION})"
    echo
    echo "Examples:"
    echo "  $0                    # Build and push with 'latest' tag"
    echo "  $0 v1.0.0            # Build and push with 'v1.0.0' tag"
    echo "  $0 2024-01-15        # Build and push with date tag"
    echo
    echo "This will push to both repositories:"
    echo "  - ${DOCKER_USERNAME}/${DEV_REPO} (public)"
    echo "  - ${DOCKER_USERNAME}/${PROD_REPO} (private)"
}

# Main execution
main() {
    # Parse arguments
    VERSION=${1:-$DEFAULT_VERSION}
    
    log "Starting Docker Hub push process..."
    log "Version: ${VERSION}"
    log "Docker Hub username: ${DOCKER_USERNAME}"
    log "Dev repository: ${DEV_REPO}"
    log "Prod repository: ${PROD_REPO}"
    
    # Pre-flight checks
    check_docker
    check_docker_login
    
    # Build and push to both repositories
    push_to_both_repos "${VERSION}"
    
    # Display final information
    echo
    success "Docker Hub push completed successfully!"
    log "Dev image: ${DOCKER_USERNAME}/${DEV_REPO}:${VERSION}"
    log "Prod image: ${DOCKER_USERNAME}/${PROD_REPO}:${VERSION}"
    echo
    log "You can now pull these images using:"
    log "  docker pull ${DOCKER_USERNAME}/${DEV_REPO}:${VERSION}"
    log "  docker pull ${DOCKER_USERNAME}/${PROD_REPO}:${VERSION}"
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