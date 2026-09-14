@echo off
setlocal enabledelayedexpansion
title FindinG - Setup Dependencies v2.0
color 0E

echo.
echo  ================================================================
echo   FindinG - Student Search Engine v2.0
echo   Windows Dependencies Setup
echo  ================================================================
echo.
echo   This script will check and install required dependencies:
echo     - Java 11 (Temurin)
echo     - Maven 3.9
echo     - MySQL 8.0
echo     - Docker Desktop (optional, recommended)
echo     - Tomcat 9 (auto-downloaded)
echo.
echo   Requires: Internet connection, Admin privileges for some installs
echo.
pause

echo.
echo [INFO] Checking admin privileges...
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo   [WARN] Not running as admin - some installs may fail
    echo   [INFO] Right-click and Run as Administrator for best results
    echo.
    pause
) else (
    echo   [OK] Running as admin
)

echo.
echo [INFO] Checking Chocolatey...
where choco >nul 2>&1
if %errorlevel% neq 0 (
    echo   [INFO] Installing Chocolatey...
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    if %errorlevel% neq 0 (
        echo   [ERROR] Failed to install Chocolatey
        echo   [INFO] Please install manually from https://chocolatey.org/install
        pause
        exit /b 1
    )
    echo   [OK] Chocolatey installed - Refreshing PATH
    call refreshenv >nul 2>&1
    set "PATH=%PATH%;%ALLUSERSPROFILE%\chocolatey\bin"
) else (
    echo   [OK] Chocolatey found
)

echo.
echo [1/4] Installing Java 11...
where java >nul 2>&1
if %errorlevel%==0 (
    echo   [OK] Java already installed
    java -version
) else (
    echo   [INFO] Installing Temurin 11 JDK via Chocolatey...
    choco install temurin11 -y --no-progress
    if %errorlevel%==0 (
        echo   [OK] Java installed
    ) else (
        echo   [WARN] Choco install failed, trying winget...
        where winget >nul 2>&1
        if %errorlevel%==0 (
            winget install EclipseAdoptium.Temurin.11.JDK --silent --accept-package-agreements
        ) else (
            echo   [ERROR] Please install Java manually: https://adoptium.net/temurin/releases/?version=11
            start https://adoptium.net/temurin/releases/?version=11
        )
    )
)

echo.
echo [2/4] Installing Maven...
where mvn >nul 2>&1
if %errorlevel%==0 (
    echo   [OK] Maven already installed
    mvn --version
) else (
    echo   [INFO] Installing Maven via Chocolatey...
    choco install maven -y --no-progress
    if %errorlevel%==0 (
        echo   [OK] Maven installed
    ) else (
        echo   [WARN] Will use Maven Wrapper or auto-download in run.bat
    )
)

echo.
echo [3/4] Installing MySQL...
where mysql >nul 2>&1
if %errorlevel%==0 (
    echo   [OK] MySQL already installed
) else (
    echo   [INFO] Installing MySQL via Chocolatey...
    choco install mysql -y --no-progress
    if %errorlevel%==0 (
        echo   [OK] MySQL installed
        echo   [INFO] Please configure MySQL root password as 'toor' or update config
    ) else (
        echo   [WARN] MySQL install may need manual setup
        echo   [INFO] Alternative: Use Docker for MySQL (recommended)
    )
)

echo.
echo [4/4] Installing Docker Desktop (Recommended - Easiest)...
where docker >nul 2>&1
if %errorlevel%==0 (
    echo   [OK] Docker already installed
    docker --version
) else (
    echo   [INFO] Installing Docker Desktop via Chocolatey...
    choco install docker-desktop -y --no-progress
    if %errorlevel%==0 (
        echo   [OK] Docker Desktop installed - Please restart computer and start Docker Desktop
    ) else (
        echo   [WARN] Docker install may require manual download
        echo   [INFO] Download from: https://www.docker.com/products/docker-desktop/
        start https://www.docker.com/products/docker-desktop/
    )
)

echo.
echo [INFO] Downloading Tomcat and building project tools...
if not exist "tools" mkdir tools

echo   [INFO] Tomcat will be auto-downloaded by run.bat on first run
echo   [INFO] No need to install manually

echo.
echo  ================================================================
echo   Setup Complete!
echo  ================================================================
echo.
echo   Summary:
echo     - Java: Check with java -version
echo     - Maven: Check with mvn -version (or will use wrapper)
echo     - MySQL: Ensure service is running
echo     - Docker: Recommended for easiest setup
echo.
echo   Next steps:
echo     1. Restart terminal / computer if Docker was installed
echo     2. Run: run.bat  (or)  run.ps1
echo     3. Open: http://localhost:8080
echo.
echo  ================================================================
echo.
pause
exit /b 0
