@REM ----------------------------------------------------------------------------
@REM Licensed to the Apache Software Foundation (ASF) under one
@REM or more contributor license agreements.  See the NOTICE file
@REM distributed with this work for additional information
@REM regarding copyright ownership.  The ASF licenses this file
@REM to you under the Apache License, Version 2.0 (the
@REM "License"); you may not use this file except in compliance
@REM with the License.  You may obtain a copy of the License at
@REM
@REM    http://www.apache.org/licenses/LICENSE-2.0
@REM
@REM Unless required by applicable law or agreed to in writing,
@REM software distributed under the License is distributed on an
@REM "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
@REM KIND, either express or implied.  See the License for the
@REM specific language governing permissions and limitations
@REM under the License.
@REM ----------------------------------------------------------------------------

@REM ----------------------------------------------------------------------------
@REM Maven Start Up Batch script - FindinG Custom Wrapper
@REM
@REM This wrapper will:
@REM 1. Check if mvn is installed globally - use it
@REM 2. Check if tools/maven exists - use it
@REM 3. Otherwise download Maven automatically
@REM ----------------------------------------------------------------------------

@echo off
setlocal

set "PROJECT_ROOT=%~dp0"
set "MAVEN_PROJECTBASEDIR=%PROJECT_ROOT%"

REM Check global Maven first
where mvn >nul 2>&1
if %errorlevel%==0 (
    echo [INFO] Using global Maven installation
    mvn %*
    exit /b %errorlevel%
)

REM Check tools/maven
if exist "%PROJECT_ROOT%tools\maven" (
    for /d %%i in ("%PROJECT_ROOT%tools\apache-maven-*") do (
        if exist "%%i\bin\mvn.cmd" (
            echo [INFO] Using tools Maven: %%i
            "%%i\bin\mvn.cmd" %*
            exit /b %errorlevel%
        )
    )
)

REM Check if we have maven in tools\maven\bin
if exist "%PROJECT_ROOT%tools\maven\bin\mvn.cmd" (
    "%PROJECT_ROOT%tools\maven\bin\mvn.cmd" %*
    exit /b %errorlevel%
)

REM Download Maven
echo [INFO] Maven not found, downloading Maven 3.9.6...
if not exist "%PROJECT_ROOT%tools" mkdir "%PROJECT_ROOT%tools"

powershell -Command "& { $ProgressPreference='SilentlyContinue'; Invoke-WebRequest -Uri 'https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip' -OutFile '%PROJECT_ROOT%tools\maven.zip' }"

if not exist "%PROJECT_ROOT%tools\maven.zip" (
    echo [ERROR] Failed to download Maven
    echo [INFO] Please install Maven manually: https://maven.apache.org/download.cgi
    exit /b 1
)

echo [INFO] Extracting Maven...
powershell -Command "Expand-Archive -Path '%PROJECT_ROOT%tools\maven.zip' -DestinationPath '%PROJECT_ROOT%tools' -Force"

for /d %%i in ("%PROJECT_ROOT%tools\apache-maven-*") do (
    echo [INFO] Maven installed to %%i
    "%%i\bin\mvn.cmd" %*
    exit /b %errorlevel%
)

echo [ERROR] Maven installation failed
exit /b 1
