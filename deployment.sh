#!/bin/bash

# Function to check if a command was successful
check_status() {
    if [ $? -ne 0 ]; then
        echo "Error: $1 failed"
        exit 1
    fi
}

# Function to pull latest changes for a given repository
git_pull() {
    echo "Pulling latest changes for $1..."
    cd "$1" || exit
    git pull
    check_status "Git pull for $1"
    cd - > /dev/null
}

# Set the paths to your repositories
APP1_PATH="/applications/Backend"
APP2_PATH="/applications/restaurant-frontend"

# Pull the latest changes from git for all repositories
git_pull "$APP1_PATH"
git_pull "$APP2_PATH"
git_pull

# Stop all running Docker containers
echo "Stopping all Docker containers..."
docker stop $(docker ps -aq)
check_status "Stopping Docker containers"

# Remove all Docker containers
echo "Removing all Docker containers..."
docker rm $(docker ps -aq)
check_status "Removing Docker containers"

# Remove all Docker images
echo "Removing all Docker images..."
docker rmi $(docker images -q)
check_status "Removing Docker images"

# Build and run Docker containers using docker-compose
echo "Building and running Docker containers..."
docker-compose up -d --build
check_status "Building and running Docker containers"

echo "Script completed successfully!"