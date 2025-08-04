# DevOps React Application

This project contains a React application with Docker containerization and deployment automation.

## Project Structure

```
devops-build-main/
├── build/                 # Built React application
├── Dockerfile            # Multi-stage Docker build
├── docker-compose.yml    # Docker Compose configuration
├── nginx.conf           # Nginx configuration for production
├── build.sh             # Build script for Docker images
├── deploy.sh            # Deployment script
├── .dockerignore        # Docker ignore file
└── README.md           # This file
```

## Prerequisites

- Docker and Docker Compose installed
- Node.js (for local development)
- SSH access to target server (for deployment)

## Quick Start

### 1. Build the Docker Image

```bash
# Make scripts executable (Linux/Mac)
chmod +x build.sh deploy.sh

# Build with default settings
./build.sh

# Build with custom name and tag
./build.sh my-app v1.0.0
```

### 2. Run with Docker Compose

```bash
# Start the application
docker-compose up -d

# View logs
docker-compose logs -f

# Stop the application
docker-compose down
```

### 3. Deploy to Server

```bash
# Deploy to localhost (default)
./deploy.sh

# Deploy to remote server
./deploy.sh my-app v1.0.0 server.com 22
```

## Docker Configuration

### Dockerfile
- Multi-stage build for optimized image size
- Uses Node.js 18 Alpine for building
- Uses Nginx Alpine for serving
- Includes security headers and optimizations

### Nginx Configuration
- Optimized for React applications
- Handles client-side routing
- Includes gzip compression
- Security headers
- Health check endpoint at `/health`

## Scripts

### build.sh
Builds and saves Docker images with the following features:
- Pre-flight checks (Docker running, required files)
- Cleanup of old images
- Multi-stage build process
- Image saving for deployment
- Colored output and logging

**Usage:**
```bash
./build.sh [image_name] [tag]
```

### deploy.sh
Deploys Docker images to servers with the following features:
- SSH connection validation
- Image transfer and loading
- Zero-downtime deployment
- Health checks
- Automatic rollback on failure
- Container management

**Usage:**
```bash
./deploy.sh [image_name] [tag] [server_host] [server_port]
```

## Environment Variables

The application can be configured using environment variables:

- `NODE_ENV`: Set to `production` for production builds
- `PORT`: Port for the application (default: 3000)

## Health Checks

The application includes a health check endpoint:
- URL: `http://your-server:3000/health`
- Returns: `200 OK` with "healthy" message

## Security Features

- Security headers in Nginx configuration
- Content Security Policy
- XSS protection
- Frame options
- Content type sniffing protection

## Troubleshooting

### Common Issues

1. **Port already in use**
   ```bash
   # Check what's using port 3000
   netstat -tulpn | grep :3000
   
   # Kill the process
   sudo kill -9 <PID>
   ```

2. **Docker build fails**
   ```bash
   # Clean Docker cache
   docker system prune -a
   
   # Rebuild without cache
   docker-compose build --no-cache
   ```

3. **SSH connection fails**
   - Verify SSH key is added to server
   - Check firewall settings
   - Ensure SSH service is running

### Logs

View application logs:
```bash
# Docker Compose logs
docker-compose logs -f

# Container logs
docker logs devops-react-app

# Nginx logs (inside container)
docker exec devops-react-app tail -f /var/log/nginx/access.log
```

## Development

For local development:

1. Install dependencies:
   ```bash
   npm install
   ```

2. Start development server:
   ```bash
   npm start
   ```

3. Build for production:
   ```bash
   npm run build
   ```

## Production Deployment

1. Build the image:
   ```bash
   ./build.sh my-app v1.0.0
   ```

2. Deploy to production server:
   ```bash
   ./deploy.sh my-app v1.0.0 production-server.com 22
   ```

3. Verify deployment:
   ```bash
   curl http://production-server.com:3000/health
   ```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License. 
