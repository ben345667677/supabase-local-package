#!/bin/bash

echo "========================================"
echo "   Supabase Local Setup & Start"
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
    echo "📦 Extracting Docker images from archive..."
    tar -xzf supabase-docker-images-*.tar.gz
    if [ $? -ne 0 ]; then
        echo "❌ Error: Failed to extract images!"
        echo "💡 Make sure supabase-docker-images-*.tar.gz exists."
        exit 1
    fi
    echo "✅ Docker images extracted!"
    echo
else
    echo "✅ Docker images directory already exists"
    echo
fi

# Load all Docker images
echo "📦 Loading Docker images..."
echo "This may take a few minutes..."
echo

for image in docker-images/*.tar; do
    if [ -f "$image" ]; then
        echo "Loading: $image"
        docker load -i "$image"
    fi
done

echo
echo "✅ All Docker images loaded!"
echo

# Start services
echo "🚀 Starting Supabase services..."
docker-compose -f docker-compose-simple.yml up -d

echo
echo "✅ Supabase is starting..."
echo "⏳ Please wait 30 seconds for services to initialize..."
sleep 30

echo
echo "🌐 Supabase is ready!"
echo
echo "📊 Service URLs:"
echo "   Studio:     http://localhost:54323"
echo "   Auth:       http://localhost:9999"
echo "   Database:   localhost:54322"
echo "   Mail Test:  http://localhost:54324"
echo
echo "💡 Database Connection:"
echo "   Host: localhost"
echo "   Port: 54322"
echo "   Database: postgres"
echo "   User: postgres"
echo "   Password: postgres"
echo
echo "🛑 To stop: docker-compose -f docker-compose-simple.yml down"
echo
echo "🎉 Supabase is ready for development!"
echo