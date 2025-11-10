@echo off
setlocal enabledelayedexpansion

echo ========================================
echo  Supabase Fast Docker Installer (OPTIMIZED)
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

REM Define required images with estimated sizes for display
set "images[0]=supabase/postgres:14.1.0.89|~500MB"
set "images[1]=supabase/studio:latest|~200MB"
set "images[2]=kong:2.8.1|~300MB"
set "images[3]=supabase/gotrue:v2.83.1|~150MB"
set "images[4]=postgrest/postgrest:v10.1.1|~100MB"
set "images[5]=supabase/postgres-meta:v0.70.0|~120MB"
set "images[6]=inbucket/inbucket:3.0.0|~80MB"

set /a "total_images=7"
set /a "downloaded=0"

echo 📊 Required Docker Images (%total_images% total):
for /l %%i in (0,1,6) do (
    for /f "tokens=1,2 delims=|" %%a in ("!images[%%i]!") do (
        echo    - %%a ^(%%b^)
    )
)
echo.

REM Check what we already have
echo 🔍 Checking existing images...
set /a "already_have=0"
for /l %%i in (0,1,6) do (
    for /f "tokens=1 delims=|" %%a in ("!images[%%i]!") do (
        docker images --format "table {{.Repository}}:{{.Tag}}" | findstr /C:"%%a" >nul
        if !errorlevel! equ 0 (
            echo ✅ %%a - Already available
            set /a "already_have+=1"
        ) else (
            echo 📥 %%a - Will be downloaded
        )
    )
)

echo.
set /a "need_download=%total_images%-%already_have%"
if %need_download% equ 0 (
    echo 🎉 All images already available! Skipping download.
    goto :verify_and_start
)

echo 📥 Need to download %need_download% images...
echo 💡 Total download size: ~1.5GB
echo ⏱️  Estimated time: 2-5 minutes (depending on connection)
echo.

REM Load from local files first
if exist "docker-images\" (
    echo 📦 Loading from local files (faster)...
    for %%i in (docker-images\*.tar) do (
        if exist "%%i" (
            echo    Loading %%~nxi...
            docker load -i "%%i" >nul 2>&1
            if !errorlevel! equ 0 (
                echo ✅ Loaded from file: %%~nxi
                set /a "downloaded+=1"
            )
        )
    )
    echo.
)

REM Download missing images in sequence (Windows doesn't easily support parallel)
echo 🌐 Downloading missing images...
for /l %%i in (0,1,6) do (
    for /f "tokens=1,2 delims=|" %%a in ("!images[%%i]!") do (
        docker images --format "table {{.Repository}}:{{.Tag}}" | findstr /C:"%%a" >nul
        if !errorlevel! neq 0 (
            echo [!downloaded!/%need_download%] 📥 %%a ^(%%b^)...
            docker pull %%a >nul 2>&1
            if !errorlevel! equ 0 (
                echo ✅ Downloaded: %%a
                set /a "downloaded+=1"
            ) else (
                echo ❌ Failed: %%a
            )
            REM Small delay between downloads
            timeout /t 1 /nobreak >nul
        )
    )
)

:verify_and_start
echo.
echo 🔍 Final verification...

set /a "ready=0"
for /l %%i in (0,1,6) do (
    for /f "tokens=1 delims=|" %%a in ("!images[%%i]!") do (
        docker images --format "table {{.Repository}}:{{.Tag}}" | findstr /C:"%%a" >nul
        if !errorlevel! equ 0 (
            set /a "ready+=1"
        )
    )
)

echo ✅ Ready images: !ready!/%total_images%
echo.

if !ready! equ %total_images% (
    echo 🎉 SUCCESS! All Docker images are ready!
    echo.
    echo 📋 Next steps:
    echo    1. Run: docker-compose -f docker-compose-simple.yml up -d
    echo    2. Access Studio: http://localhost:54323
    echo    3. Database: localhost:54322
    echo.
    echo 🚀 Want to start now? ^(y/n^)
    choice /c yn /n /m "Start Supabase now"
    if !errorlevel! equ 1 (
        echo 🚀 Starting Supabase...
        docker-compose -f docker-compose-simple.yml up -d
        echo ⏳ Waiting 30 seconds for services to initialize...
        timeout /t 30 /nobreak >nul
        echo.
        echo 🌐 Supabase is ready!
        echo    Studio: http://localhost:54323
        echo    Auth: http://localhost:9999
        echo    Database: localhost:54322
        echo    Mail Test: http://localhost:54324
    )
) else (
    echo ⚠️  Warning: Some images are still missing
    echo 💡 Try running the script again or check your internet connection
)

echo.
echo 💡 Pro tip: To stop Supabase later: docker-compose -f docker-compose-simple.yml down
pause