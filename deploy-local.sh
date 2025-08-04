#!/bin/bash

# Local deployment script for Docker images
# Usage: ./deploy-local.sh [image_name] [tag]

set -e  # Exit on any error

# Configuration
DEFAULT_IMAGE_NAME="devops-react-app"
DEFAULT_TAG="latest"
CONTAINER_NAME="devops-react-app"
HOST_PORT="3000"
CONTAINER_PORT="80"

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

# Function to check if image exists
check_image() {
    local image_name=$1
    local tag=$2
    
    if ! docker images | grep -q "${image_name}.*${tag}"; then
        error "Image ${image_name}:${tag} not found"
        error "Please run build.sh first to create the image"
        exit 1
    fi
    
    log "Image found: ${image_name}:${tag}"
}

# Function to stop existing container
stop_existing_container() {
    log "Stopping existing container..."
    
    # Stop and remove existing container
    docker stop "${CONTAINER_NAME}" 2>/dev/null || true
    docker rm "${CONTAINER_NAME}" 2>/dev/null || true
    
    success "Existing container stopped"
}

# Function to start new container
start_new_container() {
    local image_name=$1
    local tag=$2
    
    log "Starting new container..."
    
    # Start new container
    docker run -d \
        --name "${CONTAINER_NAME}" \
        --restart unless-stopped \
        -p "${HOST_PORT}:${CONTAINER_PORT}" \
        "${image_name}:${tag}"
    
    # Wait for container to start
    sleep 5
    
    # Check if container is running
    if ! docker ps | grep -q "${CONTAINER_NAME}"; then
        error "Container failed to start"
        docker logs "${CONTAINER_NAME}"
        exit 1
    fi
    
    success "New container started"
}

# Function to perform health check
perform_health_check() {
    log "Performing health check..."
    
    # Wait for application to be ready
    sleep 10
    
    # Check if application is responding
    if ! curl -f -s "http://localhost:${HOST_PORT}/health" > /dev/null 2>&1; then
        warning "Health check failed, but continuing deployment"
        return 1
    fi
    
    success "Health check passed"
    return 0
}

# Main execution
main() {
    # Parse arguments
    IMAGE_NAME=${1:-$DEFAULT_IMAGE_NAME}
    TAG=${2:-$DEFAULT_TAG}
    
    log "Starting local deployment process..."
    log "Image: ${IMAGE_NAME}:${TAG}"
    log "Port mapping: ${HOST_PORT}:${CONTAINER_PORT}"
    
    # Pre-flight checks
    check_docker
    check_image "${IMAGE_NAME}" "${TAG}"
    
    # Deployment steps
    stop_existing_container
    start_new_container "${IMAGE_NAME}" "${TAG}"
    
    # Health check
    if ! perform_health_check; then
        warning "Health check failed, but deployment completed"
    fi
    
    # Display final information
    echo
    success "Local deployment completed successfully!"
    log "Application URL: http://localhost:${HOST_PORT}"
    log "Health check URL: http://localhost:${HOST_PORT}/health"
    log "Container name: ${CONTAINER_NAME}"
}

# Handle script arguments
case "${1:-}" in
    -h|--help)
        echo "Usage: $0 [image_name] [tag]"
        echo "  image_name: Name of the Docker image (default: ${DEFAULT_IMAGE_NAME})"
        echo "  tag:        Tag for the Docker image (default: ${DEFAULT_TAG})"
        echo
        echo "Examples:"
        echo "  $0                    # Deploy with default name and latest tag"
        echo "  $0 my-app v1.0.0      # Deploy with custom name and tag"
        exit 0
        ;;
esac

# Run main function
main "$@" 
