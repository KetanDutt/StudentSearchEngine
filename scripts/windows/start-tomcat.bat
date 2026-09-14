@echo off
REM FindinG - Start Tomcat Only (assumes already built)

setlocal
set "PROJECT_ROOT=%~dp0..\.."
cd /d "%PROJECT_ROOT%"

echo ================================================================
echo  FindinG - Start Tomcat
echo ================================================================
echo.

if not exist "tools\tomcat\bin\startup.bat" (
    echo [ERROR] Tomcat not found at tools\tomcat
    echo [INFO] Run run.bat first to download Tomcat
    pause
    exit /b 1
)

if not exist "target\finding.war" (
    echo [ERROR] target\finding.war not found
    echo [INFO] Run run.bat or mvn clean package first
    pause
    exit /b 1
)

echo [INFO] Deploying war...
if exist "tools\tomcat\webapps\ROOT" rmdir /s /q "tools\tomcat\webapps\ROOT"
if exist "tools\tomcat\webapps\ROOT.war" del /q "tools\tomcat\webapps\ROOT.war"
copy /y "target\finding.war" "tools\tomcat\webapps\ROOT.war" >nul

echo [INFO] Starting Tomcat...
set "JAVA_OPTS=-Xms512m -Xmx1024m"
call tools\tomcat\bin\startup.bat

echo [INFO] Waiting 10 seconds...
timeout /t 10 /nobreak >nul

echo [INFO] Tomcat started at http://localhost:8080
start http://localhost:8080

echo [INFO] Logs: tools\tomcat\logs\catalina.out
echo [INFO] Stop: tools\tomcat\bin\shutdown.bat
pause
exit /b 0
