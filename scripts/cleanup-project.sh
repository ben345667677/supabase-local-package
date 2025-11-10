#!/bin/bash

echo "========================================"
echo "  Supabase Project Cleanup Tool"
echo "========================================"
echo

echo "🧹 This script will clean up heavy files and optimize your project"
echo

# Check current project size
echo "📊 Current project size:"
du -sh . | sed 's/^/   /'
echo

# Remove Docker archives if they exist
if ls *.tar.gz 1> /dev/null 2>&1; then
    echo "🗑️  Removing Docker archives..."
    ls -la *.tar.gz 2>/dev/null | while read -r line; do
        filename=$(echo "$line" | awk '{print $9}')
        echo "   Removing: $filename"
        rm -f "$filename"
    done
    echo "✅ Docker archives removed"
    echo
fi

if ls *.tar 1> /dev/null 2>&1; then
    echo "🗑️  Removing Docker tar files..."
    ls -la *.tar 2>/dev/null | while read -r line; do
        filename=$(echo "$line" | awk '{print $9}')
        echo "   Removing: $filename"
        rm -f "$filename"
    done
    echo "✅ Docker tar files removed"
    echo
fi

# Clean up docker-images directory if it exists
if [ -d "docker-images" ]; then
    echo "🗑️  Cleaning docker-images directory..."
    rm -rf docker-images
    echo "✅ Docker images directory removed"
    echo
fi

# Remove OS generated files
find . -name ".DS_Store" -delete 2>/dev/null
find . -name "Thumbs.db" -delete 2>/dev/null

# Remove log files
if ls *.log 1> /dev/null 2>&1; then
    echo "🗑️  Removing log files..."
    rm -f *.log
    echo "✅ Log files removed"
    echo
fi

# Clean up cache directories
if [ -d ".cache" ]; then
    echo "🗑️  Cleaning cache..."
    rm -rf .cache
    echo "✅ Cache cleaned"
    echo
fi

[ -d "temp" ] && rm -rf temp
[ -d "tmp" ] && rm -rf tmp

# Check git repository size
if [ -d ".git" ]; then
    git_size=$(du -sh .git 2>/dev/null | cut -f1)
    echo "🔥 WARNING: Git repository size: $git_size"
    echo "💡 Options to fix:"
    echo "   1. Remove heavy files from git history"
    echo "   2. Create fresh git repo"
    echo "   3. Use git filter-branch"
    echo
    echo "🚨 This will modify git history. Backup first if needed!"
    echo

    read -p "Choose cleanup option (1-3, or 0 to skip): " choice

    case $choice in
        1)
            echo "🔄 Removing heavy files from git history..."
            echo "This may take a while..."

            # Remove tar files from git history
            git filter-branch --force --index-filter "git rm --cached --ignore-unmatch '*.tar.gz'" --prune-empty --tag-name-filter cat -- --all 2>/dev/null

            # Remove docker-images directory from history
            git filter-branch --force --index-filter "git rm -rf --cached --ignore-unmatch docker-images/" --prune-empty --tag-name-filter cat -- --all 2>/dev/null

            echo "✅ Git history cleaned"
            echo "💡 Run: git gc --aggressive --prune=now to reclaim space"
            echo
            ;;
        2)
            echo "🆕 Creating fresh git repository..."
            echo "Backing up current git..."
            mv .git .git.backup

            echo "Initializing new git repository..."
            git init

            echo "Adding current files..."
            git add .
            git commit -m "Initial commit - clean project"

            echo "✅ Fresh git repository created"
            echo "💡 Old git history saved in .git.backup"
            echo
            ;;
        3)
            echo "🛠️  Running git garbage collection..."
            git reflog expire --expire=now --all
            git gc --aggressive --prune=now
            echo "✅ Git repository optimized"
            echo
            ;;
        *)
            echo "⏭️  Skipping git cleanup"
            echo
            ;;
    esac
fi

# Show final project size
echo "📊 Final project size:"
du -sh . | sed 's/^/   /'
echo

# Check if git is still huge and suggest next steps
if [ -d ".git" ]; then
    git_size=$(du -sh .git 2>/dev/null | cut -f1)
    if [[ "$git_size" == *"G"* ]]; then
        echo "⚠️  Git repository is still large: $git_size"
        echo "💡 Consider option 2 (fresh repo) for best results"
        echo
    fi
fi

echo "🎉 Cleanup complete!"
echo
echo "💡 Additional recommendations:"
echo "   1. Commit current changes to save new .gitignore"
echo "   2. Push to remote repository to sync changes"
echo "   3. Use optimized install scripts for future setup"
echo

echo "📋 Quick setup commands for fresh start:"
echo "   git add ."
echo "   git commit -m \"Add optimized project files\""
echo "   git push origin main --force"
echo