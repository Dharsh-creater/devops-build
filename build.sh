#!/bin/bash

# Build script for Docker images
# Usage: ./build.sh [image_name] [tag]

set -e  # Exit on any error

# Configuration
DEFAULT_IMAGE_NAME="devops-react-app"
DEFAULT_TAG="latest"
DOCKERFILE_PATH="."
COMPOSE_FILE="docker-compose.yml"

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

# Function to check if required files exist
check_files() {
    if [ ! -f "Dockerfile" ]; then
        error "Dockerfile not found in current directory"
        exit 1
    fi
    
    if [ ! -f "docker-compose.yml" ]; then
        error "docker-compose.yml not found in current directory"
        exit 1
    fi
    
    log "Required files found"
}

# Function to clean up old images
cleanup_old_images() {
    local image_name=$1
    local tag=$2
    
    log "Cleaning up old images..."
    
    # Remove old containers
    docker ps -a --filter "ancestor=${image_name}:${tag}" --format "{{.ID}}" | xargs -r docker rm -f
    
    # Remove old images
    docker images "${image_name}:${tag}" --format "{{.ID}}" | xargs -r docker rmi -f
    
    success "Cleanup completed"
}

# Function to build image
build_image() {
    local image_name=$1
    local tag=$2
    
    log "Building Docker image: ${image_name}:${tag}"
    
    # Build using docker-compose
    docker-compose -f ${COMPOSE_FILE} build --no-cache
    
    # Tag the image
    docker tag devops-build-main-react-app:latest "${image_name}:${tag}"
    
    success "Image built successfully: ${image_name}:${tag}"
}

# Function to save image
save_image() {
    local image_name=$1
    local tag=$2
    
    local filename="${image_name}-${tag}.tar"
    
    log "Saving image to ${filename}..."
    docker save "${image_name}:${tag}" -o "${filename}"
    
    # Get file size
    local size=$(du -h "${filename}" | cut -f1)
    success "Image saved: ${filename} (${size})"
}

# Main execution
main() {
    # Parse arguments
    IMAGE_NAME=${1:-$DEFAULT_IMAGE_NAME}
    TAG=${2:-$DEFAULT_TAG}
    
    log "Starting build process..."
    log "Image name: ${IMAGE_NAME}"
    log "Tag: ${TAG}"
    
    # Pre-flight checks
    check_docker
    check_files
    
    # Cleanup old images
    cleanup_old_images "${IMAGE_NAME}" "${TAG}"
    
    # Build new image
    build_image "${IMAGE_NAME}" "${TAG}"
    
    # Save image
    save_image "${IMAGE_NAME}" "${TAG}"
    
    # Display final information
    echo
    success "Build completed successfully!"
    log "Image: ${IMAGE_NAME}:${TAG}"
    log "File: ${IMAGE_NAME}-${TAG}.tar"
    log "To run the container: docker run -p 3000:80 ${IMAGE_NAME}:${TAG}"
}

# Handle script arguments
case "${1:-}" in
    -h|--help)
        echo "Usage: $0 [image_name] [tag]"
        echo "  image_name: Name of the Docker image (default: ${DEFAULT_IMAGE_NAME})"
        echo "  tag:        Tag for the Docker image (default: ${DEFAULT_TAG})"
        echo
        echo "Examples:"
        echo "  $0                    # Build with default name and latest tag"
        echo "  $0 my-app             # Build with custom name and latest tag"
        echo "  $0 my-app v1.0.0      # Build with custom name and tag"
        exit 0
        ;;
esac

# Run main function
main "$@" 
