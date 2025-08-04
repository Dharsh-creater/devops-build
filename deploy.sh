#!/bin/bash

# Deploy script for Docker images
# Usage: ./deploy.sh [image_name] [tag] [server_host] [server_port]

set -e  # Exit on any error

# Configuration
DEFAULT_IMAGE_NAME="devops-react-app"
DEFAULT_TAG="latest"
DEFAULT_SERVER_HOST="localhost"
DEFAULT_SERVER_PORT="22"
DEFAULT_CONTAINER_PORT="3000"
DEFAULT_HOST_PORT="3000"
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

# Function to check if image file exists
check_image_file() {
    local image_name=$1
    local tag=$2
    local filename="${image_name}-${tag}.tar"
    
    if [ ! -f "${filename}" ]; then
        error "Image file not found: ${filename}"
        error "Please run build.sh first to create the image"
        exit 1
    fi
    
    log "Image file found: ${filename}"
}

# Function to check SSH connection
check_ssh_connection() {
    local host=$1
    local port=$2
    
    log "Checking SSH connection to ${host}:${port}..."
    
    if ! ssh -p "${port}" -o ConnectTimeout=10 -o BatchMode=yes "${host}" "echo 'SSH connection successful'" > /dev/null 2>&1; then
        error "Cannot connect to server ${host}:${port}"
        error "Please check your SSH configuration and server availability"
        exit 1
    fi
    
    success "SSH connection established"
}

# Function to check Docker on remote server
check_remote_docker() {
    local host=$1
    local port=$2
    
    log "Checking Docker on remote server..."
    
    if ! ssh -p "${port}" "${host}" "docker info > /dev/null 2>&1"; then
        error "Docker is not running on remote server"
        exit 1
    fi
    
    success "Docker is available on remote server"
}

# Function to transfer image to server
transfer_image() {
    local host=$1
    local port=$2
    local image_name=$3
    local tag=$4
    local filename="${image_name}-${tag}.tar"
    
    log "Transferring image to server..."
    
    if ! scp -P "${port}" "${filename}" "${host}:/tmp/"; then
        error "Failed to transfer image to server"
        exit 1
    fi
    
    success "Image transferred successfully"
}

# Function to load image on server
load_image_on_server() {
    local host=$1
    local port=$2
    local image_name=$3
    local tag=$4
    local filename="${image_name}-${tag}.tar"
    
    log "Loading image on server..."
    
    ssh -p "${port}" "${host}" << EOF
        # Load the image
        docker load -i "/tmp/${filename}"
        
        # Clean up the tar file
        rm -f "/tmp/${filename}"
        
        # Verify image is loaded
        if ! docker images | grep -q "${image_name}.*${tag}"; then
            echo "Failed to load image"
            exit 1
        fi
EOF
    
    success "Image loaded on server"
}

# Function to stop existing container
stop_existing_container() {
    local host=$1
    local port=$2
    local container_name="devops-react-app"
    
    log "Stopping existing container..."
    
    ssh -p "${port}" "${host}" << EOF
        # Stop and remove existing container
        docker stop "${container_name}" 2>/dev/null || true
        docker rm "${container_name}" 2>/dev/null || true
        
        # Remove old images to save space
        docker image prune -f
EOF
    
    success "Existing container stopped"
}

# Function to start new container
start_new_container() {
    local host=$1
    local port=$2
    local image_name=$3
    local tag=$4
    local host_port=$5
    local container_port=$6
    
    log "Starting new container..."
    
    ssh -p "${port}" "${host}" << EOF
        # Start new container
        docker run -d \
            --name devops-react-app \
            --restart unless-stopped \
            -p ${host_port}:${container_port} \
            ${image_name}:${tag}
        
        # Wait for container to start
        sleep 5
        
        # Check if container is running
        if ! docker ps | grep -q "devops-react-app"; then
            echo "Container failed to start"
            docker logs devops-react-app
            exit 1
        fi
EOF
    
    success "New container started"
}

# Function to perform health check
perform_health_check() {
    local host=$1
    local port=$2
    local host_port=$3
    
    log "Performing health check..."
    
    # Wait for application to be ready
    sleep 10
    
    # Check if application is responding
    if ! curl -f -s "http://${host}:${host_port}/health" > /dev/null 2>&1; then
        warning "Health check failed, but continuing deployment"
        return 1
    fi
    
    success "Health check passed"
    return 0
}

# Function to rollback deployment
rollback_deployment() {
    local host=$1
    local port=$2
    local image_name=$3
    local tag=$4
    local host_port=$5
    local container_port=$6
    
    warning "Rolling back deployment..."
    
    ssh -p "${port}" "${host}" << EOF
        # Stop current container
        docker stop devops-react-app 2>/dev/null || true
        docker rm devops-react-app 2>/dev/null || true
        
        # Start previous version if available
        if docker images | grep -q "${image_name}"; then
            docker run -d \
                --name devops-react-app \
                --restart unless-stopped \
                -p ${host_port}:${container_port} \
                ${image_name}:${tag}
        fi
EOF
    
    error "Deployment rolled back"
}

# Main execution
main() {
    # Parse arguments
    IMAGE_NAME=${1:-$DEFAULT_IMAGE_NAME}
    TAG=${2:-$DEFAULT_TAG}
    SERVER_HOST=${3:-$DEFAULT_SERVER_HOST}
    SERVER_PORT=${4:-$DEFAULT_SERVER_PORT}
    
    log "Starting deployment process..."
    log "Image: ${IMAGE_NAME}:${TAG}"
    log "Server: ${SERVER_HOST}:${SERVER_PORT}"
    log "Port mapping: ${DEFAULT_HOST_PORT}:${DEFAULT_CONTAINER_PORT}"
    
    # Pre-flight checks
    check_image_file "${IMAGE_NAME}" "${TAG}"
    check_ssh_connection "${SERVER_HOST}" "${SERVER_PORT}"
    check_remote_docker "${SERVER_HOST}" "${SERVER_PORT}"
    
    # Deployment steps
    transfer_image "${SERVER_HOST}" "${SERVER_PORT}" "${IMAGE_NAME}" "${TAG}"
    load_image_on_server "${SERVER_HOST}" "${SERVER_PORT}" "${IMAGE_NAME}" "${TAG}"
    stop_existing_container "${SERVER_HOST}" "${SERVER_PORT}"
    
    # Start new container with error handling
    if ! start_new_container "${SERVER_HOST}" "${SERVER_PORT}" "${IMAGE_NAME}" "${TAG}" "${DEFAULT_HOST_PORT}" "${DEFAULT_CONTAINER_PORT}"; then
        error "Failed to start new container"
        rollback_deployment "${SERVER_HOST}" "${SERVER_PORT}" "${IMAGE_NAME}" "${TAG}" "${DEFAULT_HOST_PORT}" "${DEFAULT_CONTAINER_PORT}"
        exit 1
    fi
    
    # Health check
    if ! perform_health_check "${SERVER_HOST}" "${DEFAULT_HOST_PORT}"; then
        warning "Health check failed, but deployment completed"
    fi
    
    # Display final information
    echo
    success "Deployment completed successfully!"
    log "Application URL: http://${SERVER_HOST}:${DEFAULT_HOST_PORT}"
    log "Health check URL: http://${SERVER_HOST}:${DEFAULT_HOST_PORT}/health"
}

# Handle script arguments
case "${1:-}" in
    -h|--help)
        echo "Usage: $0 [image_name] [tag] [server_host] [server_port]"
        echo "  image_name:   Name of the Docker image (default: ${DEFAULT_IMAGE_NAME})"
        echo "  tag:          Tag for the Docker image (default: ${DEFAULT_TAG})"
        echo "  server_host:  Target server hostname/IP (default: ${DEFAULT_SERVER_HOST})"
        echo "  server_port:  SSH port for target server (default: ${DEFAULT_SERVER_PORT})"
        echo
        echo "Examples:"
        echo "  $0                                    # Deploy with all defaults"
        echo "  $0 my-app v1.0.0                     # Deploy specific image/tag to localhost"
        echo "  $0 my-app v1.0.0 server.com 2222     # Deploy to custom server and port"
        exit 0
        ;;
esac

# Run main function
main "$@" 
