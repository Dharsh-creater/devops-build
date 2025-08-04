# Jenkins Startup Script for Windows
# Run this script to start Jenkins server

Write-Host "Starting Jenkins Server..." -ForegroundColor Green
Write-Host "Jenkins will be available at: http://localhost:8080" -ForegroundColor Yellow
Write-Host "Initial admin password will be displayed below..." -ForegroundColor Yellow
Write-Host ""

# Create Jenkins home directory if it doesn't exist
$JENKINS_HOME = "$env:USERPROFILE\.jenkins"
if (!(Test-Path $JENKINS_HOME)) {
    New-Item -ItemType Directory -Path $JENKINS_HOME -Force
    Write-Host "Created Jenkins home directory: $JENKINS_HOME" -ForegroundColor Green
}

# Set Jenkins home environment variable
$env:JENKINS_HOME = $JENKINS_HOME

# Start Jenkins
Write-Host "Starting Jenkins on port 8080..." -ForegroundColor Green
java -jar jenkins.war --httpPort=8080 