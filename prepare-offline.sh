#!/bin/bash

echo "=========================================="
echo "  Prepare Supabase for Offline Server"
echo "=========================================="
echo
echo "This script will download all dependencies"
echo "and prepare them for offline installation."
echo

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

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
    echo -e "ℹ $1"
}

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is required!"
    exit 1
fi

print_success "Docker found"

# Create output directory
OUTPUT_DIR="supabase-offline-package"
print_info "Creating package directory: $OUTPUT_DIR"
rm -rf "$OUTPUT_DIR"
mkdir -p "$OUTPUT_DIR/docker-images"

# Define images to download
images=(
    "supabase/postgres:14.1.0.89"
    "supabase/studio:latest"
    "kong:2.8.1"
    "supabase/gotrue:v2.83.1"
    "postgrest/postgrest:v10.1.1"
    "supabase/postgres-meta:v0.70.0"
    "inbucket/inbucket:3.0.0"
)

print_info "Downloading Docker images..."

# Download and save each image
for image in "${images[@]}"; do
    echo
    print_info "Processing: $image"

    # Pull the image
    if docker pull "$image"; then
        print_success "Downloaded: $image"

        # Save to tar file
        safe_name=$(echo "$image" | sed 's/[\/:]/_/g')
        output_file="$OUTPUT_DIR/docker-images/${safe_name}.tar"

        if docker save "$image" -o "$output_file"; then
            print_success "Saved: $output_file"
        else
            print_error "Failed to save: $image"
        fi
    else
        print_error "Failed to download: $image"
    fi
done

echo
print_info "Creating installation script..."

# Create offline installation script
cat > "$OUTPUT_DIR/install-offline.sh" << 'EOF'
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

# Check Docker
if ! command -v docker &> /dev/null; then
    print_error "Docker is required!"
    exit 1
fi

if ! docker info &> /dev/null; then
    print_error "Docker is not running!"
    exit 1
fi

# Load Docker images
echo "Loading Docker images..."
for image_file in docker-images/*.tar; do
    if [ -f "$image_file" ]; then
        echo "Loading: $(basename "$image_file")"
        if docker load -i "$image_file"; then
            print_success "Loaded: $(basename "$image_file")"
        else
            print_error "Failed to load: $(basename "$image_file")"
        fi
    fi
done

echo
echo "Starting Supabase services..."
docker-compose -f docker-compose-simple.yml up -d

echo
echo "Waiting for services to start..."
sleep 60

echo
print_success "Supabase installation complete!"
echo
echo "Access URLs:"
echo "Studio: http://localhost:54323"
echo "Auth: http://localhost:9999"
echo "Database: localhost:54322"
EOF

chmod +x "$OUTPUT_DIR/install-offline.sh"

# Copy project files
print_info "Copying project files..."
cp -r .env docker-compose-simple.yml kong.yml supabase/ scripts/ docs/ README.md "$OUTPUT_DIR/" 2>/dev/null || true

# Remove unnecessary scripts
rm -f "$OUTPUT_DIR/scripts/setup-and-start.sh" "$OUTPUT_DIR/scripts/install-*.sh" 2>/dev/null || true

# Create README for offline package
cat > "$OUTPUT_DIR/README-OFFLINE.md" << 'EOF'
# Supabase Offline Installation

## Installation
```bash
./install-offline.sh
```

## Access
- Studio: http://localhost:54323
- Auth: http://localhost:9999
- Database: localhost:54322

## Management
```bash
# Stop
docker-compose -f docker-compose-simple.yml down

# Start
docker-compose -f docker-compose-simple.yml up -d

# Logs
docker-compose -f docker-compose-simple.yml logs -f
```
EOF

# Create archive
print_info "Creating offline package archive..."
cd "$OUTPUT_DIR"
tar -czf "../supabase-offline-package.tar.gz" .
cd ..

# Clean up
print_info "Cleaning up..."
rm -rf "$OUTPUT_DIR"

echo
print_success "Offline package ready: supabase-offline-package.tar.gz"
echo
echo "Package contains:"
echo "- All Docker images"
echo "- Project files"
echo "- Installation script"
echo
echo "Transfer supabase-offline-package.tar.gz to offline server"
echo "Extract and run: ./install-offline.sh"