@echo off
REM FindinG - Windows Dependencies Installer
REM Standalone installer script

title FindinG - Install Dependencies

echo ================================================================
echo  FindinG - Dependency Installer
echo ================================================================
echo.

REM Check admin
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo [WARN] Please run as Administrator for best results
    pause
)

echo [INFO] This will install:
echo   - Chocolatey (package manager)
echo   - Java 11 JDK
echo   - Maven
echo   - MySQL
echo   - Docker Desktop (optional)
echo.

set /p choice="Continue? (Y/n): "
if /i "%choice%"=="n" exit /b 0

call "%~dp0..\..\setup.bat"

exit /b 0
