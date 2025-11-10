@echo off
setlocal enabledelayedexpansion

echo ========================================
echo    Supabase Project Cleanup Tool
echo ========================================
echo.

echo 🧹 This script will clean up heavy files and optimize your project
echo.

REM Check current project size
echo 📊 Current project size:
for /f "tokens=3" %%a in ('dir /-c ^| find "bytes"') do (
    set "total_size=%%a"
    echo    Total: %%a bytes
)
echo.

REM Remove Docker archives if they exist
if exist "*.tar.gz" (
    echo 🗑️  Removing Docker archives...
    for %%f in (*.tar.gz) do (
        echo    Removing: %%f
        del "%%f"
    )
    echo ✅ Docker archives removed
    echo.
)

if exist "*.tar" (
    echo 🗑️  Removing Docker tar files...
    for %%f in (*.tar) do (
        echo    Removing: %%f
        del "%%f"
    )
    echo ✅ Docker tar files removed
    echo.
)

REM Clean up docker-images directory if it exists
if exist "docker-images\" (
    echo 🗑️  Cleaning docker-images directory...
    rmdir /s /q "docker-images"
    echo ✅ Docker images directory removed
    echo.
)

REM Remove OS generated files
if exist ".DS_Store" del ".DS_Store" 2>nul
if exist "Thumbs.db" del "Thumbs.db" 2>nul

REM Remove log files
if exist "*.log" (
    echo 🗑️  Removing log files...
    del "*.log" 2>nul
    echo ✅ Log files removed
    echo.
)

REM Clean up cache directories
if exist ".cache\" (
    echo 🗑️  Cleaning cache...
    rmdir /s /q ".cache" 2>nul
    echo ✅ Cache cleaned
    echo.
)

if exist "temp\" (
    rmdir /s /q "temp" 2>nul
)

if exist "tmp\" (
    rmdir /s /q "tmp" 2>nul
)

REM Clean up git repository (this is the big one)
echo 🔥 WARNING: Git repository is huge (2GB+)
echo 💡 Options to fix:
echo    1. Remove heavy files from git history
echo    2. Create fresh git repo
echo    3. Use git filter-branch
echo.
echo 🚨 This will modify git history. Backup first if needed!
echo.

set /p "choice=Choose cleanup option (1-3, or 0 to skip): "

if "%choice%"=="1" (
    echo 🔄 Removing heavy files from git history...
    echo This may take a while...

    REM Remove tar files from git history
    git filter-branch --force --index-filter "git rm --cached --ignore-unmatch *.tar.gz" --prune-empty --tag-name-filter cat -- --all 2>nul

    REM Remove docker-images directory from history
    git filter-branch --force --index-filter "git rm -rf --cached --ignore-unmatch docker-images/" --prune-empty --tag-name-filter cat -- --all 2>nul

    echo ✅ Git history cleaned
    echo 💡 Run: git gc --aggressive --prune=now to reclaim space
    echo.
) else if "%choice%"=="2" (
    echo 🆕 Creating fresh git repository...
    echo Backing up current git...
    ren .git .git.backup

    echo Initializing new git repository...
    git init

    echo Adding current files...
    git add .
    git commit -m "Initial commit - clean project"

    echo ✅ Fresh git repository created
    echo 💡 Old git history saved in .git.backup
    echo.
) else if "%choice%"=="3" (
    echo 🛠️  Running git garbage collection...
    git reflog expire --expire=now --all
    git gc --aggressive --prune=now
    echo ✅ Git repository optimized
    echo.
) else (
    echo ⏭️  Skipping git cleanup
    echo.
)

REM Show final project size
echo 📊 Final project size:
for /f "tokens=3" %%a in ('dir /-c ^| find "bytes"') do (
    echo    Total: %%a bytes
)
echo.

echo 🎉 Cleanup complete!
echo.
echo 💡 Additional recommendations:
echo    1. Commit current changes to save new .gitignore
echo    2. Push to remote repository to sync changes
echo    3. Use optimized install scripts for future setup
echo.

pause