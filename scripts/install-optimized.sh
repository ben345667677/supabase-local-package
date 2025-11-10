#!/bin/bash

echo "========================================"
echo " Supabase Fast Docker Installer (OPTIMIZED)"
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

# Define required images with estimated sizes
declare -A images=(
    ["supabase/postgres:14.1.0.89"]="~500MB"
    ["supabase/studio:latest"]="~200MB"
    ["kong:2.8.1"]="~300MB"
    ["supabase/gotrue:v2.83.1"]="~150MB"
    ["postgrest/postgrest:v10.1.1"]="~100MB"
    ["supabase/postgres-meta:v0.70.0"]="~120MB"
    ["inbucket/inbucket:3.0.0"]="~80MB"
)

total_images=${#images[@]}
downloaded=0

echo "📊 Required Docker Images ($total_images total):"
for image in "${!images[@]}"; do
    echo "   - $image (${images[$image]})"
done
echo

# Check what we already have
echo "🔍 Checking existing images..."
already_have=0
for image in "${!images[@]}"; do
    if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
        echo "✅ $image - Already available"
        ((already_have++))
    else
        echo "📥 $image - Will be downloaded"
    fi
done

echo
need_download=$((total_images - already_have))
if [ $need_download -eq 0 ]; then
    echo "🎉 All images already available! Skipping download."
    verify_and_start
    exit 0
fi

echo "📥 Need to download $need_download images..."
echo "💡 Total download size: ~1.5GB"
echo "⏱️  Estimated time: 2-5 minutes (depending on connection)"
echo

# Load from local files first
if [ -d "docker-images" ]; then
    echo "📦 Loading from local files (faster)..."
    for image_file in docker-images/*.tar; do
        if [ -f "$image_file" ]; then
            echo "   Loading $(basename "$image_file")..."
            if docker load -i "$image_file" >/dev/null 2>&1; then
                echo "✅ Loaded from file: $(basename "$image_file")"
                ((downloaded++))
            fi
        fi
    done
    echo
fi

# Function to download image with progress
download_image() {
    local image=$1
    local size=$2

    if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
        echo "✅ $image - Already available"
        return 0
    fi

    echo "[$((downloaded+1))/$need_download] 📥 $image ($size)..."

    # Pull with progress
    if docker pull "$image" 2>&1 | while IFS= read -r line; do
        if [[ $line =~ [0-9]+\.[0-9]+[A-Z]*\/[0-9]+\.[0-9]+[A-Z]* ]]; then
            echo "     $line"
        fi
    done; then
        echo "✅ Downloaded: $image"
        ((downloaded++))
        return 0
    else
        echo "❌ Failed: $image"
        return 1
    fi
}

# Download missing images in parallel (if supported)
echo "🌐 Downloading missing images..."
echo

# Check if we can use parallel processing
if command -v xargs >/dev/null 2>&1 && command -v parallel >/dev/null 2>&1; then
    echo "🚀 Using parallel download..."
    printf '%s\n' "${!images[@]}" | head -n $need_download | parallel -j 3 download_image {} {}
else
    echo "📥 Sequential download..."
    for image in "${!images[@]}"; do
        if ! docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
            download_image "$image" "${images[$image]}"
            sleep 1  # Small delay between downloads
        fi
    done
fi

verify_and_start

verify_and_start() {
    echo
    echo "🔍 Final verification..."

    ready=0
    for image in "${!images[@]}"; do
        if docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
            ((ready++))
        fi
    done

    echo "✅ Ready images: $ready/$total_images"
    echo

    if [ $ready -eq $total_images ]; then
        echo "🎉 SUCCESS! All Docker images are ready!"
        echo
        echo "📋 Next steps:"
        echo "   1. Run: docker-compose -f docker-compose-simple.yml up -d"
        echo "   2. Access Studio: http://localhost:54323"
        echo "   3. Database: localhost:54322"
        echo
        echo "🚀 Want to start now? (y/n)"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            echo "🚀 Starting Supabase..."
            docker-compose -f docker-compose-simple.yml up -d
            echo "⏳ Waiting 30 seconds for services to initialize..."
            sleep 30
            echo
            echo "🌐 Supabase is ready!"
            echo "   Studio: http://localhost:54323"
            echo "   Auth: http://localhost:9999"
            echo "   Database: localhost:54322"
            echo "   Mail Test: http://localhost:54324"
        fi
    else
        echo "⚠️  Warning: Some images are still missing"
        echo "💡 Try running the script again or check your internet connection"
    fi

    echo
    echo "💡 Pro tip: To stop Supabase later: docker-compose -f docker-compose-simple.yml down"
}