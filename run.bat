@echo off
setlocal enabledelayedexpansion
title FindinG - One Click Runner v2.0
color 0B

echo.
echo  ================================================================
echo   FindinG - Student Search Engine v2.0
echo   One-Click Windows Runner ^| Production Ready
echo  ================================================================
echo.
echo   [INFO] Starting automated setup and launch...
echo.

REM Set project root
set "PROJECT_ROOT=%~dp0"
cd /d "%PROJECT_ROOT%"

REM Create tools directory
if not exist "tools" mkdir tools
if not exist "logs" mkdir logs

echo [1/7] Checking Java...
java -version >nul 2>&1
if %errorlevel% neq 0 (
    echo   [ERROR] Java not found!
    echo   [INFO] Trying to find Java in common locations...
    set "JAVA_FOUND=0"
    if exist "C:\Program Files\Java\jdk-11\bin\java.exe" set "JAVA_FOUND=1" & set "JAVA_HOME=C:\Program Files\Java\jdk-11"
    if exist "C:\Program Files\Eclipse Adoptium\jdk-11*\bin\java.exe" set "JAVA_FOUND=1"
    if exist "%ProgramFiles%\Java\*\bin\java.exe" set "JAVA_FOUND=1"
    
    if "!JAVA_FOUND!"=="0" (
        echo   [ACTION] Please install Java 11 or higher:
        echo     - Download from: https://adoptium.net/temurin/releases/?version=11
        echo     - Or via Chocolatey: choco install temurin11 -y
        echo     - Or via Winget: winget install EclipseAdoptium.Temurin.11.JDK
        echo.
        echo   [INFO] Opening Java download page...
        start https://adoptium.net/temurin/releases/?version=11
        pause
        exit /b 1
    )
) else (
    for /f "tokens=3" %%g in ('java -version 2^>^&1 ^| findstr /i "version"') do (
        echo   [OK] Java found: %%g
    )
)

echo.
echo [2/7] Checking Docker (preferred)...
docker --version >nul 2>&1
if %errorlevel%==0 (
    echo   [OK] Docker found
    docker-compose --version >nul 2>&1
    if %errorlevel%==0 (
        echo   [INFO] Docker Compose found - Using Docker deployment (EASIEST)
        echo.
        echo   [INFO] Building and starting containers...
        echo   [INFO] This will start MySQL + Tomcat automatically
        echo.
        docker-compose up --build -d
        if %errorlevel%==0 (
            echo.
            echo   [SUCCESS] Containers started!
            echo   [INFO] Waiting 30 seconds for services to be ready...
            timeout /t 30 /nobreak >nul
            echo   [INFO] Checking health...
            docker-compose ps
            echo.
            echo   ================================================================
            echo    SUCCESS! Application is running
            echo   ================================================================
            echo    URL: http://localhost:8080
            echo    Health: http://localhost:8080/health.jsp
            echo    Demo Student: student1 / Student@123
            echo    Demo Company: company1 / Company@123
            echo   ================================================================
            echo    To stop: docker-compose down
            echo    Logs: docker-compose logs -f
            echo   ================================================================
            echo.
            start http://localhost:8080
            pause
            exit /b 0
        ) else (
            echo   [WARN] Docker Compose failed, trying manual setup...
        )
    ) else (
        echo   [WARN] Docker Compose not found, trying manual setup...
    )
) else (
    echo   [INFO] Docker not found - Using manual Tomcat deployment
)

echo.
echo [3/7] Checking Maven...
set "MVN_CMD="
if exist "mvnw.cmd" (
    set "MVN_CMD=call mvnw.cmd"
    echo   [OK] Maven Wrapper found: mvnw.cmd
) else (
    mvn --version >nul 2>&1
    if %errorlevel%==0 (
        set "MVN_CMD=mvn"
        echo   [OK] Maven found
    ) else (
        echo   [WARN] Maven not found, will download...
        echo   [INFO] Downloading Maven 3.9.6...
        if not exist "tools\maven" mkdir tools\maven
        powershell -Command "& { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip' -OutFile 'tools\maven.zip' }"
        if exist "tools\maven.zip" (
            echo   [INFO] Extracting Maven...
            powershell -Command "Expand-Archive -Path 'tools\maven.zip' -DestinationPath 'tools' -Force"
            for /d %%i in (tools\apache-maven-*) do set "MAVEN_HOME=%%i"
            set "MVN_CMD=!MAVEN_HOME!\bin\mvn.cmd"
            echo   [OK] Maven installed to !MAVEN_HOME!
        ) else (
            echo   [ERROR] Failed to download Maven
            echo   [INFO] Please install Maven manually: https://maven.apache.org/download.cgi
            echo   [INFO] Or via Chocolatey: choco install maven -y
            start https://maven.apache.org/download.cgi
            pause
            exit /b 1
        )
    )
)

echo.
echo [4/7] Checking MySQL...
set "MYSQL_OK=0"
mysql --version >nul 2>&1
if %errorlevel%==0 (
    echo   [OK] MySQL client found
    echo   [INFO] Testing connection to localhost:3306...
    mysql -u root -ptoor -e "SELECT 1" >nul 2>&1
    if %errorlevel%==0 (
        echo   [OK] MySQL connection successful (root/toor)
        set "MYSQL_OK=1"
    ) else (
        echo   [WARN] MySQL running but root/toor failed, trying without password...
        mysql -u root -e "SELECT 1" >nul 2>&1
        if %errorlevel%==0 (
            echo   [OK] MySQL connection successful (root no password)
            set "MYSQL_OK=1"
            echo   [INFO] Creating database and user...
            mysql -u root -e "CREATE DATABASE IF NOT EXISTS project CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'finding_user'@'localhost' IDENTIFIED BY 'finding_pass_2026'; GRANT ALL ON project.* TO 'finding_user'@'localhost'; FLUSH PRIVILEGES;" >nul 2>&1
        )
    )
)

if "!MYSQL_OK!"=="0" (
    echo   [WARN] MySQL not available or not configured
    echo   [INFO] Attempting to start MySQL via Docker if possible...
    docker --version >nul 2>&1
    if %errorlevel%==0 (
        echo   [INFO] Starting MySQL container only...
        docker run -d --name finding_mysql_temp -e MYSQL_ROOT_PASSWORD=toor -e MYSQL_DATABASE=project -p 3306:3306 mysql:8.0 >nul 2>&1
        echo   [INFO] Waiting 20 seconds for MySQL to start...
        timeout /t 20 /nobreak >nul
        set "MYSQL_OK=1"
    ) else (
        echo   [INFO] No Docker, please ensure MySQL is installed and running
        echo   [INFO] Download MySQL: https://dev.mysql.com/downloads/installer/
        echo   [INFO] Or via Chocolatey: choco install mysql -y
        echo.
        echo   [INFO] You can still build the project, but DB features will fail until MySQL is ready
        echo   [INFO] Press any key to continue with build anyway...
        pause >nul
    )
)

echo.
echo [5/7] Building project...
echo   [INFO] Running: %MVN_CMD% clean package -DskipTests
%MVN_CMD% clean package -DskipTests
if %errorlevel% neq 0 (
    echo   [ERROR] Build failed!
    echo   [INFO] Check logs above
    echo   [INFO] Trying to find existing war...
    if not exist "target\finding.war" (
        echo   [ERROR] No war file found in target/
        pause
        exit /b 1
    ) else (
        echo   [WARN] Build failed but war exists, continuing...
    )
) else (
    echo   [OK] Build successful!
    if exist "target\finding.war" (
        echo   [OK] War file: target\finding.war
    )
)

echo.
echo [6/7] Setting up Tomcat...
if not exist "tools\tomcat" (
    echo   [INFO] Downloading Tomcat 9.0.85...
    if not exist "tools" mkdir tools
    powershell -Command "& { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.zip' -OutFile 'tools\tomcat.zip' }"
    if exist "tools\tomcat.zip" (
        echo   [INFO] Extracting Tomcat...
        powershell -Command "Expand-Archive -Path 'tools\tomcat.zip' -DestinationPath 'tools' -Force"
        for /d %%i in (tools\apache-tomcat-*) do (
            if not exist "tools\tomcat" (
                move "%%i" "tools\tomcat" >nul
            )
        )
        echo   [OK] Tomcat installed to tools\tomcat
    ) else (
        echo   [ERROR] Failed to download Tomcat
        echo   [INFO] Please download manually: https://tomcat.apache.org/download-90.cgi
        start https://tomcat.apache.org/download-90.cgi
        pause
        exit /b 1
    )
) else (
    echo   [OK] Tomcat found: tools\tomcat
)

echo   [INFO] Deploying war to Tomcat...
if exist "tools\tomcat\webapps\ROOT" rmdir /s /q "tools\tomcat\webapps\ROOT" >nul 2>&1
if exist "tools\tomcat\webapps\ROOT.war" del /q "tools\tomcat\webapps\ROOT.war" >nul 2>&1
copy /y "target\finding.war" "tools\tomcat\webapps\ROOT.war" >nul

echo   [INFO] Initializing database...
if "!MYSQL_OK!"=="1" (
    echo   [INFO] Running sql/init.sql...
    mysql -u root -ptoor project < sql\init.sql >nul 2>&1
    if %errorlevel% neq 0 (
        mysql -u root project < sql\init.sql >nul 2>&1
    )
    echo   [OK] Database initialized with demo data
) else (
    echo   [WARN] Skipping DB init - MySQL not available
)

echo.
echo [7/7] Starting Tomcat...
echo   [INFO] Starting Tomcat on port 8080...
cd /d "%PROJECT_ROOT%"

REM Set JAVA_OPTS for better performance
set "JAVA_OPTS=-Xms512m -Xmx1024m -XX:+UseG1GC"

REM Start Tomcat in new window
start "FindinG Tomcat" /min tools\tomcat\bin\startup.bat

echo   [INFO] Waiting 15 seconds for Tomcat to start...
timeout /t 15 /nobreak >nul

REM Check if Tomcat started
netstat -an | findstr ":8080" | findstr "LISTENING" >nul 2>&1
if %errorlevel%==0 (
    echo   [OK] Tomcat is listening on port 8080
) else (
    echo   [WARN] Tomcat may still be starting, check logs
)

echo.
echo  ================================================================
echo   SUCCESS! FindinG is running!
echo  ================================================================
echo.
echo    URL: http://localhost:8080
echo    Health Check: http://localhost:8080/health.jsp
echo.
echo    Demo Accounts:
echo      Student:  student1 / Student@123
echo      Company:  company1 / Company@123
echo.
echo    Tomcat Logs: tools\tomcat\logs\catalina.out
echo    Stop Server: tools\tomcat\bin\shutdown.bat
echo    Or: docker-compose down (if using Docker)
echo.
echo  ================================================================
echo    Opening browser...
echo  ================================================================
echo.

REM Open browser
start http://localhost:8080

echo   [INFO] Press any key to view logs or keep this window open
echo   [INFO] To stop the server, run: tools\tomcat\bin\shutdown.bat
echo.
pause

REM Show logs
if exist "tools\tomcat\logs\catalina.out" (
    echo   [INFO] Last 20 lines of Tomcat log:
    powershell -Command "Get-Content -Tail 20 'tools\tomcat\logs\catalina.out'"
)

echo.
echo   [INFO] Server is running in background
echo   [INFO] Close this window or press any key to exit (server will keep running)
pause
exit /b 0
