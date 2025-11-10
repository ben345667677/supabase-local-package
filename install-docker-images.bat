@echo off
echo ========================================
echo    Supabase Local Docker Installer
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if %errorlevel% neq 0 (
    echo ❌ Error: Docker is not installed or not running!
    echo 💡 Please install Docker Desktop first.
    pause
    exit /b 1
)

echo ✅ Docker found
echo.

REM Check if docker-images directory exists
if not exist "docker-images" (
    echo 📦 Looking for Docker images archive...
    if exist "supabase-docker-images-*.tar.gz" (
        echo 📦 Extracting Docker images from archive...
        tar -xzf supabase-docker-images-*.tar.gz
        if %errorlevel% neq 0 (
            echo ❌ Error: Failed to extract images!
            echo 💡 Make sure supabase-docker-images-*.tar.gz exists.
            pause
            exit /b 1
        )
        echo ✅ Docker images extracted!
    ) else (
        echo ❌ Error: docker-images directory not found and no archive found!
        echo 💡 Please place supabase-docker-images-*.tar.gz in this directory.
        pause
        exit /b 1
    )
) else (
    echo ✅ Docker images directory already exists
)

echo.
echo 📦 Loading Docker images...
echo This may take a few minutes...
echo.

REM Define required images
set "required_images=supabase/postgres:14.1.0.89 supabase/studio:latest kong:2.8.1 supabase/gotrue:v2.83.1 postgrest/postgrest:v10.1.1 supabase/postgres-meta:v0.70.0 inbucket/inbucket:3.0.0"

REM First, try to load from local files if they exist
if exist "docker-images\" (
    echo 📦 Loading Docker images from local files...
    for %%i in (docker-images\*.tar) do (
        if exist "%%i" (
            echo Loading: %%i
            docker load -i "%%i"
            if %errorlevel% neq 0 (
                echo ❌ Error loading %%i
            ) else (
                echo ✅ Loaded %%i
            )
        )
    )
    echo.
)

REM Pull missing images from Docker Hub
echo 🌐 Checking and pulling missing images from Docker Hub...
echo.

for %%i in (%required_images%) do (
    docker images --format "table {{.Repository}}:{{.Tag}}" | findstr /C:"%%i" >nul
    if %errorlevel% neq 0 (
        echo 📥 Pulling %%i from Docker Hub...
        docker pull %%i
        if %errorlevel% neq 0 (
            echo ❌ Failed to pull %%i
        ) else (
            echo ✅ Pulled %%i
        )
    ) else (
        echo ✅ Image %%i already available
    )
)

echo.
echo ✅ All Docker images processed!
echo.

REM Final check
echo 🔍 Final verification of all required images...

for %%i in (%required_images%) do (
    docker images --format "table {{.Repository}}:{{.Tag}}" | findstr /C:"%%i" >nul
    if %errorlevel% neq 0 (
        echo ⚠️  Warning: Image %%i still not found
    ) else (
        echo ✅ Image %%i is ready
    )
)

echo.
echo 🎉 Docker installation complete!
echo.
echo 📋 Next steps:
echo    1. Run: docker-compose -f docker-compose-simple.yml up -d
echo    2. Access Studio: http://localhost:54323
echo    3. Database: localhost:54322
echo.
pause