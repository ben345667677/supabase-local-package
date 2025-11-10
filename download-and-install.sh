#!/bin/bash

echo "=========================================="
echo "  Supabase Local - Download & Install"
echo "=========================================="
echo

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_step() {
    echo -e "${BLUE}[STEP]${NC} $1"
}

# Check if Docker is installed
check_docker() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not running!"
        echo "Please install Docker Desktop first: https://docker.com"
        exit 1
    fi
    print_status "Docker found and running"
}

# Check if Docker images exist locally
check_local_images() {
    print_step "Checking for local Docker images..."

    local images=(
        "supabase/postgres:14.1.0.89"
        "supabase/studio:latest"
        "kong:2.8.1"
        "supabase/gotrue:v2.83.1"
        "postgrest/postgrest:v10.1.1"
        "supabase/postgres-meta:v0.70.0"
        "inbucket/inbucket:3.0.0"
    )

    local missing_images=0

    for image in "${images[@]}"; do
        if ! docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
            print_warning "Missing image: $image"
            missing_images=$((missing_images + 1))
        fi
    done

    if [ $missing_images -eq 0 ]; then
        print_status "All Docker images found locally!"
        return 0
    else
        print_warning "$missing_images images missing"
        return 1
    fi
}

# Download Docker images from remote registry
download_images() {
    print_step "Downloading Docker images from registry..."
    echo "This may take a few minutes depending on your connection speed..."
    echo

    local images=(
        "supabase/postgres:14.1.0.89"
        "supabase/studio:latest"
        "kong:2.8.1"
        "supabase/gotrue:v2.83.1"
        "postgrest/postgrest:v10.1.1"
        "supabase/postgres-meta:v0.70.0"
        "inbucket/inbucket:3.0.0"
    )

    for image in "${images[@]}"; do
        print_status "Downloading: $image"
        if docker pull "$image"; then
            print_status "✓ Downloaded: $image"
        else
            print_error "✗ Failed to download: $image"
        fi
    done

    echo
    print_status "All Docker images downloaded!"
}

# Load Docker images from local archive
load_local_archive() {
    print_step "Loading Docker images from local archive..."

    if [ ! -f "supabase-docker-images-*.tar.gz" ]; then
        print_error "No Docker archive found!"
        echo "Please place supabase-docker-images-*.tar.gz in the current directory"
        return 1
    fi

    # Extract archive
    print_status "Extracting Docker images archive..."
    if ! tar -xzf supabase-docker-images-*.tar.gz; then
        print_error "Failed to extract archive!"
        return 1
    fi

    # Load all images
    for image in docker-images/*.tar; do
        if [ -f "$image" ]; then
            print_status "Loading: $(basename "$image")"
            if docker load -i "$image"; then
                print_status "✓ Loaded: $(basename "$image")"
            else
                print_error "✗ Failed to load: $(basename "$image")"
            fi
        fi
    done

    # Clean up extracted files
    rm -rf docker-images
    print_status "✓ All Docker images loaded successfully!"
}

# Verify environment file
verify_env() {
    if [ ! -f ".env" ]; then
        print_warning ".env file not found, using default configuration"
        return 0
    fi
    print_status ".env file found"
}

# Start Supabase services
start_supabase() {
    print_step "Starting Supabase services..."

    if docker-compose -f docker-compose-simple.yml up -d; then
        print_status "✓ Services started successfully!"
    else
        print_error "✗ Failed to start services"
        return 1
    fi
}

# Wait for services to be ready
wait_for_services() {
    print_step "Waiting for services to initialize..."
    echo "This may take 30-60 seconds..."

    # Wait for database
    local max_attempts=30
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if docker-compose -f docker-compose-simple.yml exec supabase-db pg_isready -U postgres >/dev/null 2>&1; then
            print_status "✓ Database is ready!"
            break
        fi
        attempt=$((attempt + 1))
        sleep 2
        echo -n "."
    done

    echo
    sleep 10  # Extra time for other services
    print_status "✓ All services should be ready now!"
}

# Display service information
display_info() {
    echo
    print_status "🎉 Supabase is ready for development!"
    echo
    echo "==================================="
    echo "🌐 Service URLs:"
    echo "==================================="
    echo "🎨 Studio:     http://localhost:54323"
    echo "🔐 Auth:        http://localhost:9999"
    echo "🗄️ Database:    localhost:54322"
    echo "📧 Mail Test:   http://localhost:54324"
    echo "🌐 API:         http://localhost:54321"
    echo
    echo "==================================="
    echo "🔑 Database Connection:"
    echo "==================================="
    echo "Host: localhost"
    echo "Port: 54322"
    echo "Database: postgres"
    echo "User: postgres"
    echo "Password: postgres"
    echo
    echo "==================================="
    echo "🛑 Management Commands:"
    echo "==================================="
    echo "Stop:     docker-compose -f docker-compose-simple.yml down"
    echo "Restart:  docker-compose -f docker-compose-simple.yml restart"
    echo "Logs:     docker-compose -f docker-compose-simple.yml logs -f"
    echo "Status:   docker-compose -f docker-compose-simple.yml ps"
    echo
    echo "🎉 Happy coding with Supabase!"
}

# Main execution
main() {
    echo "Starting Supabase installation process..."
    echo

    # Check prerequisites
    check_docker
    verify_env

    echo
    echo "Choose installation method:"
    echo "1) Download from Docker Hub (requires internet)"
    echo "2) Load from local archive (faster, requires supabase-docker-images-*.tar.gz)"
    echo "3) Check existing images only"
    echo
    read -p "Enter choice (1-3): " choice

    echo
    case $choice in
        1)
            print_step "Downloading images from Docker Hub..."
            download_images
            ;;
        2)
            print_step "Loading images from local archive..."
            if ! load_local_archive; then
                print_error "Failed to load from archive, falling back to download..."
                download_images
            fi
            ;;
        3)
            if ! check_local_images; then
                print_warning "Some images are missing, downloading them..."
                download_images
            fi
            ;;
        *)
            print_error "Invalid choice. Defaulting to download..."
            download_images
            ;;
    esac

    # Start services
    if start_supabase; then
        wait_for_services
        display_info
    else
        print_error "Installation failed!"
        exit 1
    fi
}

# Run main function
main "$@"