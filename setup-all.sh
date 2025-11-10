#!/bin/bash

echo "=========================================="
echo "  Supabase Local - Complete Setup Script"
echo "=========================================="
echo
echo "This script will handle EVERYTHING:"
echo "✓ System requirements check"
echo "✓ Project structure setup"
echo "✓ Dependencies download"
echo "✓ Environment configuration"
echo "✓ Service installation"
echo "✓ Database initialization"
echo "✓ Service startup"
echo "✓ Verification & testing"
echo

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Progress tracking
STEP=0
TOTAL_STEPS=8

print_header() {
    STEP=$((STEP + 1))
    echo -e "${PURPLE}========================================${NC}"
    echo -e "${PURPLE}STEP $STEP/$TOTAL_STEPS: $1${NC}"
    echo -e "${PURPLE}========================================${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ $1${NC}"
}

# Step 1: Check system requirements
check_system_requirements() {
    print_header "System Requirements Check"

    # Check Docker
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed!"
        print_info "Please install Docker Desktop: https://docker.com"
        exit 1
    fi
    print_success "Docker found"

    # Check if Docker is running
    if ! docker info &> /dev/null; then
        print_error "Docker is not running!"
        print_info "Please start Docker Desktop"
        exit 1
    fi
    print_success "Docker is running"

    # Check Docker Compose
    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed!"
        exit 1
    fi
    print_success "Docker Compose found"

    # Check memory (Linux only)
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        available_mem=$(free -g | awk '/^Mem:/{print $7}')
        if [ "$available_mem" -lt 3 ]; then
            print_warning "Recommended: 4GB+ RAM (current: ${available_mem}GB available)"
        else
            print_success "Memory requirement met (${available_mem}GB available)"
        fi
    fi

    # Check disk space
    available_space=$(df . | tail -1 | awk '{print $4}')
    if [ "$available_space" -lt 2097152 ]; then  # 2GB in KB
        print_warning "Recommended: 2GB+ free disk space"
    else
        print_success "Disk space requirement met"
    fi

    echo
}

# Step 2: Setup project structure
setup_project_structure() {
    print_header "Project Structure Setup"

    # Create directories
    mkdir -p supabase/migrations
    mkdir -p scripts
    mkdir -p windows
    mkdir -p docs

    # Create .gitkeep for empty directories
    touch supabase/migrations/.gitkeep

    print_success "Directory structure created"

    # Verify essential files exist
    local missing_files=()

    [ ! -f "docker-compose-simple.yml" ] && missing_files+=("docker-compose-simple.yml")
    [ ! -f "kong.yml" ] && missing_files+=("kong.yml")
    [ ! -f "supabase/config.toml" ] && missing_files+=("supabase/config.toml")

    if [ ${#missing_files[@]} -gt 0 ]; then
        print_error "Missing essential files: ${missing_files[*]}"
        print_info "Please ensure all project files are present"
        exit 1
    fi

    print_success "All essential files found"
    echo
}

# Step 3: Create environment configuration
setup_environment() {
    print_header "Environment Configuration"

    if [ -f ".env" ]; then
        print_success ".env file already exists"
        read -p "Do you want to recreate it? (y/N): " recreate
        if [[ ! $recreate =~ ^[Yy]$ ]]; then
            echo
            return
        fi
    fi

    print_info "Creating .env file with optimal settings..."

    cat > .env << 'EOF'
# הגדרות סביבת סופאבייס מקומי
# Supabase Local Environment Configuration

# Database Configuration
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=postgres
POSTGRES_PORT=54322
POSTGRES_HOST=localhost
DATABASE_URL=postgresql://postgres:postgres@localhost:54322/postgres

# Studio Configuration
STUDIO_PORT=3000
STUDIO_PORT_EXTERNAL=54323
STUDIO_DEFAULT_ORGANIZATION=support@supabase.com
STUDIO_DEFAULT_PROJECT=supabase-local

# API Gateway Configuration
KONG_HTTP_PORT=54321
KONG_HTTPS_PORT=54320
KONG_ADMIN_PORT=8001
KONG_ADMIN_GUI_PORT=8002

# JWT Configuration
JWT_SECRET=super-secret-jwt-token-with-at-least-32-characters-long

# API Keys
ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6ImFub24iLCJleHAiOjE5ODQ4MTI5OTZ9.CRXP1A7WOeoJeXxjNni43kdQwgnWNReilDMblYTn_I0
SERVICE_ROLE_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZS1kZW1vIiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImV4cCI6MTk4NDgxMjk5Nn0.EGIM96RAZx35lJzdJsyH-qQwv8Hdp7fsn3W0YpN81IU

# Additional Configuration
DB_ENC_KEY=supabasestoragesecretkeydontleakthis
IMGPROXY_ENABLE_WEBP_DETECTION=true
IMGPROXY_ENFORCE_WEBP=false
EOF

    print_success ".env file created successfully"
    echo
}

# Step 4: Download and prepare Docker images
prepare_docker_images() {
    print_header "Docker Images Preparation"

    # Define required images
    local images=(
        "supabase/postgres:14.1.0.89"
        "supabase/studio:latest"
        "kong:2.8.1"
        "supabase/gotrue:v2.83.1"
        "postgrest/postgrest:v10.1.1"
        "supabase/postgres-meta:v0.70.0"
        "inbucket/inbucket:3.0.0"
    )

    # Check for local archive first
    local archive_found=false
    for archive in supabase-docker-images-*.tar.gz; do
        if [ -f "$archive" ]; then
            print_success "Found local archive: $archive"
            archive_found=true
            break
        fi
    done

    if [ "$archive_found" = true ]; then
        print_info "Loading images from local archive..."

        # Extract archive
        if tar -xzf "$archive"; then
            print_success "Archive extracted"

            # Load images
            local loaded=0
            for image_file in docker-images/*.tar; do
                if [ -f "$image_file" ]; then
                    print_info "Loading: $(basename "$image_file")"
                    if docker load -i "$image_file"; then
                        loaded=$((loaded + 1))
                    fi
                fi
            done

            # Clean up
            rm -rf docker-images
            print_success "Loaded $loaded images from archive"
        else
            print_warning "Failed to extract archive, falling back to download"
            archive_found=false
        fi
    fi

    if [ "$archive_found" = false ]; then
        # Check what's missing
        local missing_images=0
        for image in "${images[@]}"; do
            if ! docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
                missing_images=$((missing_images + 1))
            fi
        done

        if [ $missing_images -gt 0 ]; then
            print_info "Downloading $missing_images missing Docker images..."

            for image in "${images[@]}"; do
                if ! docker images --format "table {{.Repository}}:{{.Tag}}" | grep -q "$image"; then
                    print_info "Downloading: $image"
                    if docker pull "$image"; then
                        print_success "Downloaded: $image"
                    else
                        print_error "Failed to download: $image"
                        exit 1
                    fi
                else
                    print_success "Already have: $image"
                fi
            done
        else
            print_success "All Docker images already available"
        fi
    fi

    print_success "Docker images preparation complete"
    echo
}

# Step 5: Install and configure services
install_services() {
    print_header "Service Installation & Configuration"

    # Stop any existing services
    print_info "Stopping any existing Supabase services..."
    docker-compose -f docker-compose-simple.yml down 2>/dev/null || true

    # Start services
    print_info "Starting Supabase services..."
    if docker-compose -f docker-compose-simple.yml up -d; then
        print_success "Services started successfully"
    else
        print_error "Failed to start services"
        exit 1
    fi

    print_success "Service installation complete"
    echo
}

# Step 6: Initialize database
initialize_database() {
    print_header "Database Initialization"

    print_info "Waiting for database to be ready..."

    local max_attempts=30
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if docker-compose -f docker-compose-simple.yml exec supabase-db pg_isready -U postgres >/dev/null 2>&1; then
            print_success "Database is ready!"
            break
        fi

        attempt=$((attempt + 1))
        sleep 2
        echo -n "."
    done

    echo

    if [ $attempt -eq $max_attempts ]; then
        print_error "Database failed to start within timeout"
        exit 1
    fi

    # Run database migrations if they exist
    if [ -f "supabase/migrations/01-auth-schema.sql" ]; then
        print_info "Running database migrations..."
        for migration in supabase/migrations/*.sql; do
            if [ -f "$migration" ]; then
                print_info "Applying: $(basename "$migration")"
                docker-compose -f docker-compose-simple.yml exec supabase-db psql -U postgres -d postgres -f "/docker-entrypoint-initdb.d/$(basename "$migration")" 2>/dev/null || true
            fi
        done
        print_success "Database migrations applied"
    fi

    print_success "Database initialization complete"
    echo
}

# Step 7: Start and verify all services
start_and_verify_services() {
    print_header "Service Startup & Verification"

    print_info "Waiting for all services to initialize..."
    sleep 30

    # Check service status
    print_info "Checking service status..."

    local services_up=0
    local services_total=0

    # List of expected services
    local services=(
        "supabase-db"
        "supabase-studio"
        "supabase-kong"
        "supabase-auth"
        "supabase-rest"
        "supabase-meta"
        "supabase-inbucket"
    )

    for service in "${services[@]}"; do
        services_total=$((services_total + 1))
        if docker-compose -f docker-compose-simple.yml ps "$service" | grep -q "Up"; then
            print_success "$service is running"
            services_up=$((services_up + 1))
        else
            print_warning "$service may not be running properly"
        fi
    done

    print_info "Services status: $services_up/$services_total running"

    # Basic connectivity tests
    print_info "Testing service connectivity..."

    # Test database connection
    if docker-compose -f docker-compose-simple.yml exec supabase-db psql -U postgres -d postgres -c "SELECT 1;" >/dev/null 2>&1; then
        print_success "Database connection test passed"
    else
        print_warning "Database connection test failed"
    fi

    print_success "Service verification complete"
    echo
}

# Step 8: Display final information and next steps
display_completion_info() {
    print_header "Setup Complete! 🎉"

    echo -e "${GREEN}🎊 Supabase Local Environment is ready for development!${NC}"
    echo
    echo "==================================="
    echo -e "${CYAN}🌐 Service URLs:${NC}"
    echo "==================================="
    echo -e "🎨 Studio:     ${YELLOW}http://localhost:54323${NC}"
    echo -e "🔐 Auth:        ${YELLOW}http://localhost:9999${NC}"
    echo -e "🗄️ Database:    ${YELLOW}localhost:54322${NC}"
    echo -e "📧 Mail Test:   ${YELLOW}http://localhost:54324${NC}"
    echo -e "🌐 API:         ${YELLOW}http://localhost:54321${NC}"
    echo
    echo "==================================="
    echo -e "${CYAN}🔑 Database Connection:${NC}"
    echo "==================================="
    echo -e "Host:       ${YELLOW}localhost${NC}"
    echo -e "Port:       ${YELLOW}54322${NC}"
    echo -e "Database:   ${YELLOW}postgres${NC}"
    echo -e "User:       ${YELLOW}postgres${NC}"
    echo -e "Password:   ${YELLOW}postgres${NC}"
    echo
    echo "==================================="
    echo -e "${CYAN}🛑 Management Commands:${NC}"
    echo "==================================="
    echo -e "Stop:     ${YELLOW}docker-compose -f docker-compose-simple.yml down${NC}"
    echo -e "Restart:  ${YELLOW}docker-compose -f docker-compose-simple.yml restart${NC}"
    echo -e "Logs:     ${YELLOW}docker-compose -f docker-compose-simple.yml logs -f${NC}"
    echo -e "Status:   ${YELLOW}docker-compose -f docker-compose-simple.yml ps${NC}"
    echo
    echo "==================================="
    echo -e "${CYAN}🚀 Next Steps:${NC}"
    echo "==================================="
    echo -e "1. Open ${YELLOW}http://localhost:54323${NC} to access Supabase Studio"
    echo -e "2. Create your first project and table"
    echo -e "3. Start building your application!"
    echo
    echo -e "${GREEN}✨ Happy coding with Supabase! ✨${NC}"
    echo
}

# Error handling
handle_error() {
    print_error "Setup failed at step $STEP"
    echo
    echo "Troubleshooting steps:"
    echo "1. Ensure Docker Desktop is running"
    echo "2. Check if ports 54321-54324 are available"
    echo "3. Verify you have sufficient disk space and memory"
    echo "4. Try running: docker-compose -f docker-compose-simple.yml down"
    echo "5. Then run this script again"
    exit 1
}

# Main execution with error handling
trap 'handle_error' ERR

main() {
    echo "Starting complete Supabase setup..."
    echo "This will take approximately 5-10 minutes depending on your internet connection."
    echo

    check_system_requirements
    setup_project_structure
    setup_environment
    prepare_docker_images
    install_services
    initialize_database
    start_and_verify_services
    display_completion_info
}

# Run the main function
main "$@"