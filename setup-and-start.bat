@echo off
echo ========================================
echo   Supabase Local Setup & Start
echo ========================================
echo.

REM Check if Docker is installed
docker --version >nul 2>&1
if errorlevel 1 (
    echo ❌ Error: Docker is not installed or not running!
    echo 💡 Please install Docker Desktop first.
    pause
    exit /b 1
)

echo ✅ Docker found
echo.

REM Check if docker-images directory exists
if not exist "docker-images" (
    echo 📦 Extracting Docker images from archive...
    tar -xzf supabase-docker-images-*.tar.gz
    if errorlevel 1 (
        echo ❌ Error: Failed to extract images!
        echo 💡 Make sure supabase-docker-images-*.tar.gz exists.
        pause
        exit /b 1
    )
    echo ✅ Docker images extracted!
    echo.
) else (
    echo ✅ Docker images directory already exists
    echo.
)

REM Load all Docker images
echo 📦 Loading Docker images...
echo This may take a few minutes...
echo.

for %%f in (docker-images\*.tar) do (
    echo Loading: %%f
    docker load -i "%%f"
)

echo.
echo ✅ All Docker images loaded!
echo.

REM Start services
echo 🚀 Starting Supabase services...
docker-compose -f docker-compose-simple.yml up -d

echo.
echo ✅ Supabase is starting...
echo ⏳ Please wait 30 seconds for services to initialize...
timeout /t 30 /nobreak >nul

echo.
echo 🌐 Supabase is ready!
echo.
echo 📊 Service URLs:
echo    Studio:     http://localhost:54323
echo    Auth:       http://localhost:9999
echo    Database:   localhost:54322
echo    Mail Test:  http://localhost:54324
echo.
echo 💡 Database Connection:
echo    Host: localhost
echo    Port: 54322
echo    Database: postgres
echo    User: postgres
echo    Password: postgres
echo.
echo 🛑 To stop: docker-compose -f docker-compose-simple.yml down
echo.
echo 🎉 Supabase is ready for development!
echo.
pause