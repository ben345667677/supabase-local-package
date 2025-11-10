#!/bin/bash

echo "=========================================="
echo "  Install Supabase (Offline Mode)"
echo "=========================================="
echo

print_success() {
    echo -e "✓ $1"
}

print_error() {
    echo -e "✗ $1"
}

print_info() {
    echo -e "ℹ $1"
}

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is required!"
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker is not running!"
    exit 1
fi

print_success "Docker is running"

# Load Docker images
print_info "Loading Docker images..."
loaded_count=0
total_images=$(ls docker-images/*.tar 2>/dev/null | wc -l)

for image_file in docker-images/*.tar; do
    if [ -f "$image_file" ]; then
        print_info "Loading: $(basename "$image_file")"
        if docker load -i "$image_file"; then
            print_success "Loaded: $(basename "$image_file")"
            loaded_count=$((loaded_count + 1))
        else
            print_error "Failed to load: $(basename "$image_file")"
        fi
    fi
done

print_success "Loaded $loaded_count/$total_images Docker images"

# Create .env if not exists
if [ ! -f ".env" ]; then
    print_info "Creating .env file..."
    cat > .env << 'EOF'
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
EOF
    print_success ".env file created"
fi

# Stop existing services
print_info "Stopping any existing services..."
docker-compose -f docker-compose-simple.yml down 2>/dev/null || true

# Start services
print_info "Starting Supabase services..."
if docker-compose -f docker-compose-simple.yml up -d; then
    print_success "Services started successfully"
else
    print_error "Failed to start services"
    exit 1
fi

# Wait for services
print_info "Waiting for services to initialize..."
echo "This may take 60-120 seconds..."

# Wait for database
max_attempts=60
attempt=0

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
sleep 20

echo
print_success "Supabase installation complete!"
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
echo "Host:       localhost"
echo "Port:       54322"
echo "Database:   postgres"
echo "User:       postgres"
echo "Password:   postgres"
echo
echo "==================================="
echo "🛑 Management Commands:"
echo "==================================="
echo "Stop:     docker-compose -f docker-compose-simple.yml down"
echo "Restart:  docker-compose -f docker-compose-simple.yml restart"
echo "Logs:     docker-compose -f docker-compose-simple.yml logs -f"
echo "Status:   docker-compose -f docker-compose-simple.yml ps"
echo
echo "🎉 Supabase is ready for development!"