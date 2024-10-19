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

# Function to build a single service
build_service() {
    local service=$1
    echo "Building $service..."
    docker-compose build $service
    check_status "Building $service"
}

# Function to start a single service
start_service() {
    local service=$1
    echo "Starting $service..."
    docker-compose up -d --no-deps $service
    check_status "Starting $service"
}

# Set the paths to your repositories
APP1_PATH="/applications/Backend"
APP2_PATH="/applications/restaurant-frontend"

# Pull the latest changes from git for all repositories
git_pull "$APP1_PATH"
git_pull "$APP2_PATH"

# Stop all running Docker containers
echo "Stopping all Docker containers..."
if [ -n "$(docker ps -q)" ]; then
    docker stop $(docker ps -q)
    check_status "Stopping Docker containers"
else
    echo "No running containers to stop."
fi

# Remove all Docker containers
echo "Removing all Docker containers..."
if [ -n "$(docker ps -aq)" ]; then
    docker rm $(docker ps -aq)
    check_status "Removing Docker containers"
else
    echo "No containers to remove."
fi

# Remove all Docker images
echo "Removing all Docker images..."
if [ -n "$(docker images -q)" ]; then
    docker rmi $(docker images -q)
    check_status "Removing Docker images"
else
    echo "No images to remove."
fi

# Get all services from docker-compose.yml
services=$(docker-compose config --services)

# Build all services one by one
echo "Building all services..."
for service in $services
do
    build_service $service
done

# Start all services one by one
echo "Starting all services..."
for service in $services
do
    start_service $service
done

echo "Script completed successfully!"