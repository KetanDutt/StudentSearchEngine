@echo off
setlocal
title FindinG - WebApp Runner v2.0
color 0D

echo.
echo  ================================================================
echo   FindinG - WebApp Runner (Tomcat Only, No Docker)
echo  ================================================================
echo.
echo   This script runs the webapp using embedded Tomcat,
echo   without Docker. It will:
echo     - Check Java 11+
echo     - Check/Download Maven
echo     - Build the war
echo     - Download Tomcat 9 if needed
echo     - Deploy and start
echo.

set "PROJECT_ROOT=%~dp0"
cd /d "%PROJECT_ROOT%"

REM Check Java
echo [1/5] Checking Java...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [ERROR] Java not found! Install Java 11 from https://adoptium.net
    start https://adoptium.net/temurin/releases/?version=11
    pause
    exit /b 1
)
echo   [OK] Java found

REM Maven
echo.
echo [2/5] Checking Maven...
set "MVN_CMD="
if exist "mvnw.cmd" (
    set "MVN_CMD=call mvnw.cmd"
    echo   [OK] Maven Wrapper
) else (
    where mvn >nul 2>&1
    if %errorlevel%==0 (
        set "MVN_CMD=mvn"
        echo   [OK] Maven found
    ) else (
        echo   [INFO] Downloading Maven...
        if not exist "tools" mkdir tools
        powershell -Command "Invoke-WebRequest -Uri 'https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip' -OutFile 'tools\maven.zip'"
        powershell -Command "Expand-Archive -Path 'tools\maven.zip' -DestinationPath 'tools' -Force"
        for /d %%i in (tools\apache-maven-*) do set "MAVEN_HOME=%%i"
        set "MVN_CMD=!MAVEN_HOME!\bin\mvn.cmd"
    )
)

REM Build
echo.
echo [3/5] Building...
%MVN_CMD% clean package -DskipTests
if %errorlevel% neq 0 (
    echo   [ERROR] Build failed
    pause
    exit /b 1
)
echo   [OK] Build success

REM Tomcat
echo.
echo [4/5] Setting up Tomcat...
if not exist "tools\tomcat" (
    echo   [INFO] Downloading Tomcat 9...
    powershell -Command "Invoke-WebRequest -Uri 'https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.zip' -OutFile 'tools\tomcat.zip'"
    powershell -Command "Expand-Archive -Path 'tools\tomcat.zip' -DestinationPath 'tools' -Force"
    for /d %%i in (tools\apache-tomcat-*) do move "%%i" "tools\tomcat" >nul 2>&1
)
echo   [OK] Tomcat ready

echo   [INFO] Deploying...
if exist "tools\tomcat\webapps\ROOT" rmdir /s /q "tools\tomcat\webapps\ROOT"
if exist "tools\tomcat\webapps\ROOT.war" del /q "tools\tomcat\webapps\ROOT.war"
copy /y "target\finding.war" "tools\tomcat\webapps\ROOT.war" >nul

REM Start
echo.
echo [5/5] Starting Tomcat...
set "JAVA_OPTS=-Xms512m -Xmx1024m"
start "FindinG Tomcat" /min tools\tomcat\bin\startup.bat
timeout /t 10 /nobreak >nul

echo.
echo  ================================================================
echo   SUCCESS! http://localhost:8080
echo   Demo: student1 / Student@123
echo   Logs: tools\tomcat\logs\catalina.out
echo   Stop: tools\tomcat\bin\shutdown.bat
echo  ================================================================
echo.
start http://localhost:8080
pause
exit /b 0
