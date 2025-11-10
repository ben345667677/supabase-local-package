#!/bin/bash

echo "========================================"
echo "   Supabase Local Docker Installer"
echo "========================================"
echo

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    echo "❌ Error: Docker is not installed or not running!"
    echo "💡 Please install Docker Desktop first."
    exit 1
fi

echo "✅ Docker found"
echo

# Check if docker-images directory exists
if [ ! -d "docker-images" ]; then
    echo "📦 Looking for Docker images archive..."
    if ls supabase-docker-images-*.tar.gz 1> /dev/null 2>&1; then
        echo "📦 Extracting Docker images from archive..."
        tar -xzf supabase-docker-images-*.tar.gz
        if [ $? -ne 0 ]; then
            echo "❌ Error: Failed to extract images!"
            echo "💡 Make sure supabase-docker-images-*.tar.gz exists."
            exit 1
        fi
        echo "✅ Docker images extracted!"
    else
        echo "❌ Error: docker-images directory not found and no archive found!"
        echo "💡 Please place supabase-docker-images-*.tar.gz in this directory."
        exit 1
    fi
else
    echo "✅ Docker images directory already exists"
fi

echo
echo "📦 Loading Docker images..."
echo "This may take a few minutes..."
echo

# Define required images
required_images=(
    "supabase/postgres:14.1.0.89"
    "supabase/studio:latest"
    "kong:2.8.1"
    "supabase/gotrue:v2.83.1"
    "postgrest/postgrest:v10.1.1"
    "supabase/postgres-meta:v0.70.0"
    "inbucket/inbucket:3.0.0"
)

# First, try to load from local files if they exist
if [ -d "docker-images" ]; then
    echo "📦 Loading Docker images from local files..."
    for image in docker-images/*.tar; do
        if [ -f "$image" ]; then
            echo "Loading: $image"
            docker load -i "$image"
            if [ $? -eq 0 ]; then
                echo "✅ Loaded $image"
            else
                echo "❌ Error loading $image"
            fi
        fi
    done
    echo
fi

# Pull missing images from Docker Hub
echo "🌐 Checking and pulling missing images from Docker Hub..."
echo

missing_images=()

for image in "${required_images[@]}"; do
    if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
        echo "✅ Image $image already available"
    else
        echo "📥 Pulling $image from Docker Hub..."
        docker pull "$image"
        if [ $? -eq 0 ]; then
            echo "✅ Pulled $image"
        else
            echo "❌ Failed to pull $image"
            missing_images+=("$image")
        fi
    fi
done

echo
echo "✅ All Docker images processed!"
echo

# Final check
echo "🔍 Final verification of all required images..."

for image in "${required_images[@]}"; do
    if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
        echo "✅ Image $image is ready"
    else
        echo "⚠️  Warning: Image $image still not found"
    fi
done

echo
echo "🎉 Docker installation complete!"
echo
echo "📋 Next steps:"
echo "    1. Run: docker-compose -f docker-compose-simple.yml up -d"
echo "    2. Access Studio: http://localhost:54323"
echo "    3. Database: localhost:54322"
echo

if [ ${#missing_images[@]} -gt 0 ]; then
    echo "⚠️  Some images are missing. You may need to pull them:"
    for image in "${missing_images[@]}"; do
        echo "    docker pull $image"
    done
    echo
fi

echo "🛑 To stop: docker-compose -f docker-compose-simple.yml down"
echo "🧹 To clean: docker system prune -f"