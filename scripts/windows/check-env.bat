@echo off
REM FindinG - Environment Checker

echo ================================================================
echo  FindinG - Environment Check
echo ================================================================
echo.

echo [1] Java...
java -version 2>&1
if %errorlevel%==0 (
    echo   [OK] Java found
) else (
    echo   [FAIL] Java not found - Need Java 11+
)
echo.

echo [2] Maven...
mvn --version 2>&1 | head -n 1
if %errorlevel%==0 (
    echo   [OK] Maven found
) else (
    echo   [INFO] Maven not found - Will use wrapper or auto-download
)
echo.

echo [3] MySQL...
mysql --version 2>&1
if %errorlevel%==0 (
    echo   [OK] MySQL client found
    echo   Testing connection...
    mysql -u root -ptoor -e "SELECT 1" >nul 2>&1
    if %errorlevel%==0 (
        echo   [OK] MySQL connection OK (root/toor)
    ) else (
        mysql -u root -e "SELECT 1" >nul 2>&1
        if %errorlevel%==0 (
            echo   [OK] MySQL connection OK (root no password)
        ) else (
            echo   [WARN] MySQL running but auth failed
        )
    )
) else (
    echo   [FAIL] MySQL not found
)
echo.

echo [4] Docker...
docker --version 2>&1
if %errorlevel%==0 (
    echo   [OK] Docker found
    docker-compose --version 2>&1
    if %errorlevel%==0 (
        echo   [OK] Docker Compose found
    ) else (
        echo   [INFO] Checking docker compose (new)...
        docker compose version 2>&1
    )
) else (
    echo   [FAIL] Docker not found - Manual setup will be used
)
echo.

echo [5] Tomcat...
if exist "..\..\tools\tomcat\bin\startup.bat" (
    echo   [OK] Tomcat found at tools\tomcat
) else (
    echo   [INFO] Tomcat not found - Will auto-download on run
)
echo.

echo [6] Build...
if exist "..\..\target\finding.war" (
    echo   [OK] War file exists: target\finding.war
    dir ..\..\target\finding.war | findstr "finding.war"
) else (
    echo   [INFO] War not built yet - Run mvn clean package
)
echo.

echo ================================================================
echo  Check Complete - See above for status
echo ================================================================
echo.
echo  If any FAIL, run setup.bat or run.bat with auto-install
echo.
pause
exit /b 0
