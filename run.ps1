# FindinG - One Click Windows Runner v2.0 (PowerShell)
# Production-ready automated setup with dependency auto-installation

param(
    [switch]$UseDocker = $false,
    [switch]$SkipBuild = $false,
    [switch]$InstallDeps = $false,
    [int]$Port = 8080
)

$ErrorActionPreference = "Continue"
$ProgressPreference = "SilentlyContinue"

# Colors
function Write-Color {
    param([string]$Text, [string]$Color = "White")
    Write-Host $Text -ForegroundColor $Color
}

function Write-Step {
    param([string]$Text)
    Write-Host "`n[$((Get-Date).ToString('HH:mm:ss'))] $Text" -ForegroundColor Cyan
}

function Write-OK {
    param([string]$Text)
    Write-Host "  [OK] $Text" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Text)
    Write-Host "  [WARN] $Text" -ForegroundColor Yellow
}

function Write-ErrorMsg {
    param([string]$Text)
    Write-Host "  [ERROR] $Text" -ForegroundColor Red
}

function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    } catch {
        return $false
    }
}

function Install-Chocolatey {
    Write-Step "Installing Chocolatey (Windows Package Manager)..."
    if (Test-Command "choco") {
        Write-OK "Chocolatey already installed"
        return $true
    }
    try {
        Set-ExecutionPolicy Bypass -Scope Process -Force
        [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
        Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
        Write-OK "Chocolatey installed"
        return $true
    } catch {
        Write-ErrorMsg "Failed to install Chocolatey: $_"
        return $false
    }
}

function Install-Dependency {
    param([string]$Package, [string]$TestCommand)
    if (Test-Command $TestCommand) {
        Write-OK "$Package already installed"
        return $true
    }
    
    Write-Step "Installing $Package..."
    if (Test-Command "choco") {
        try {
            choco install $Package -y --no-progress
            $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
            Write-OK "$Package installed via Chocolatey"
            return $true
        } catch {
            Write-Warn "Choco install failed for $Package : $_"
        }
    }
    
    if (Test-Command "winget") {
        try {
            winget install --id $Package -e --silent --accept-package-agreements
            Write-OK "$Package installed via Winget"
            return $true
        } catch {
            Write-Warn "Winget install failed for $Package"
        }
    }
    
    Write-Warn "Please install $Package manually"
    return $false
}

# Banner
Clear-Host
Write-Host @"
  ================================================================
   FindinG - Student Search Engine v2.0
   One-Click PowerShell Runner | Production Ready
  ================================================================
   Automated setup with dependency checking & auto-installation
  ================================================================
"@ -ForegroundColor Magenta

$ProjectRoot = $PSScriptRoot
Set-Location $ProjectRoot

# Create directories
@("tools", "logs", "target") | ForEach-Object {
    if (-not (Test-Path $_)) { New-Item -ItemType Directory -Path $_ -Force | Out-Null }
}

# Step 1: Java
Write-Step "[1/7] Checking Java 11+..."
$javaFound = $false
try {
    $javaVersion = java -version 2>&1 | Out-String
    if ($javaVersion -match 'version "(\d+)') {
        $major = [int]$Matches[1]
        if ($major -ge 11) {
            Write-OK "Java $major found"
            $javaFound = $true
        } else {
            Write-Warn "Java $major found but need 11+, upgrading..."
        }
    }
} catch {}

if (-not $javaFound -or $InstallDeps) {
    Write-Host "  [INFO] Java 11+ required. Attempting auto-install..." -ForegroundColor Yellow
    if (-not (Test-Command "choco")) { Install-Chocolatey | Out-Null }
    
    $installed = $false
    if (Test-Command "choco") {
        try {
            choco install temurin11 -y --no-progress
            $installed = $true
        } catch {}
    }
    if (-not $installed -and (Test-Command "winget")) {
        try {
            winget install EclipseAdoptium.Temurin.11.JDK --silent --accept-package-agreements
            $installed = $true
        } catch {}
    }
    
    if (-not $installed) {
        Write-ErrorMsg "Java not found. Please install Java 11:"
        Write-Host "    https://adoptium.net/temurin/releases/?version=11" -ForegroundColor Cyan
        Start-Process "https://adoptium.net/temurin/releases/?version=11"
        Read-Host "Press Enter after installing Java, or Ctrl+C to exit"
    } else {
        Write-OK "Java installed, refreshing PATH..."
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
}

# Step 2: Docker (preferred)
Write-Step "[2/7] Checking Docker (preferred deployment)..."
$useDocker = $false
if ((Test-Command "docker") -and (Test-Command "docker-compose" -or (docker compose version 2>&1 | Out-Null; $?))) {
    Write-OK "Docker found"
    if ($UseDocker -or (-not $InstallDeps)) {
        Write-Host "  [INFO] Docker deployment is EASIEST - 1 command runs MySQL+Tomcat" -ForegroundColor Green
        $choice = Read-Host "  Use Docker? (Y/n)"
        if ($choice -eq "" -or $choice -match "^[Yy]") { $useDocker = $true }
    }
} else {
    Write-Host "  [INFO] Docker not found - will use manual Tomcat" -ForegroundColor Yellow
    if ($InstallDeps) {
        Write-Host "  [INFO] Installing Docker Desktop..." -ForegroundColor Yellow
        Install-Dependency -Package "docker-desktop" -TestCommand "docker" | Out-Null
    }
}

if ($useDocker) {
    Write-Step "Starting with Docker Compose..."
    try {
        # Try docker compose (new) then docker-compose (old)
        $composeCmd = if (Test-Command "docker-compose") { "docker-compose" } else { "docker compose" }
        Invoke-Expression "$composeCmd up --build -d"
        Write-OK "Containers started!"
        Write-Host "  Waiting 30s for services..." -ForegroundColor Yellow
        Start-Sleep -Seconds 30
        Invoke-Expression "$composeCmd ps"
        
        Write-Host @"
  ================================================================
   SUCCESS! Application running via Docker
  ================================================================
    URL: http://localhost:8080
    Health: http://localhost:8080/health.jsp
    Demo Student: student1 / Student@123
    Demo Company: company1 / Company@123
  ================================================================
    Stop: $composeCmd down
    Logs: $composeCmd logs -f
  ================================================================
"@ -ForegroundColor Green
        
        Start-Process "http://localhost:8080"
        Read-Host "Press Enter to exit (containers will keep running)"
        exit 0
    } catch {
        Write-ErrorMsg "Docker Compose failed: $_"
        Write-Host "  Falling back to manual setup..." -ForegroundColor Yellow
    }
}

# Step 3: Maven
Write-Step "[3/7] Checking Maven..."
$mavenCmd = $null
if (Test-Path ".\mvnw.cmd") {
    $mavenCmd = ".\mvnw.cmd"
    Write-OK "Maven Wrapper found: mvnw.cmd"
} elseif (Test-Command "mvn") {
    $mavenCmd = "mvn"
    Write-OK "Maven found"
} else {
    Write-Host "  [INFO] Maven not found, downloading..." -ForegroundColor Yellow
    $mavenUrl = "https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.zip"
    $zipPath = ".\tools\maven.zip"
    try {
        Invoke-WebRequest -Uri $mavenUrl -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath ".\tools" -Force
        $mavenHome = Get-ChildItem ".\tools\apache-maven-*" -Directory | Select-Object -First 1
        $mavenCmd = Join-Path $mavenHome.FullName "bin\mvn.cmd"
        Write-OK "Maven installed to $($mavenHome.FullName)"
    } catch {
        Write-ErrorMsg "Failed to download Maven: $_"
        Write-Host "  Please install Maven: https://maven.apache.org/download.cgi" -ForegroundColor Cyan
        Start-Process "https://maven.apache.org/download.cgi"
        exit 1
    }
}

# Step 4: MySQL
Write-Step "[4/7] Checking MySQL..."
$mysqlOk = $false
try {
    $null = mysql --version 2>&1
    Write-OK "MySQL client found"
    try {
        $null = mysql -u root -ptoor -e "SELECT 1" 2>&1
        Write-OK "MySQL connection OK (root/toor)"
        $mysqlOk = $true
    } catch {
        try {
            $null = mysql -u root -e "SELECT 1" 2>&1
            Write-OK "MySQL connection OK (root no password)"
            Write-Host "  Creating database..." -ForegroundColor Yellow
            mysql -u root -e "CREATE DATABASE IF NOT EXISTS project CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'finding_user'@'localhost' IDENTIFIED BY 'finding_pass_2026'; GRANT ALL ON project.* TO 'finding_user'@'localhost'; FLUSH PRIVILEGES;" 2>&1 | Out-Null
            $mysqlOk = $true
        } catch {
            Write-Warn "MySQL running but connection failed"
        }
    }
} catch {
    Write-Warn "MySQL not found"
    if ($InstallDeps) {
        Write-Host "  Installing MySQL via Chocolatey..." -ForegroundColor Yellow
        Install-Dependency -Package "mysql" -TestCommand "mysql" | Out-Null
    }
}

if (-not $mysqlOk -and (Test-Command "docker")) {
    Write-Host "  Starting MySQL via Docker container..." -ForegroundColor Yellow
    try {
        docker run -d --name finding_mysql_temp -e MYSQL_ROOT_PASSWORD=toor -e MYSQL_DATABASE=project -p 3306:3306 mysql:8.0 2>&1 | Out-Null
        Write-Host "  Waiting 20s for MySQL..." -ForegroundColor Yellow
        Start-Sleep -Seconds 20
        $mysqlOk = $true
    } catch {
        Write-Warn "Failed to start MySQL container"
    }
}

# Step 5: Build
if (-not $SkipBuild) {
    Write-Step "[5/7] Building project..."
    Write-Host "  Running: $mavenCmd clean package -DskipTests" -ForegroundColor Gray
    try {
        Invoke-Expression "$mavenCmd clean package -DskipTests"
        if ($LASTEXITCODE -eq 0) {
            Write-OK "Build successful!"
        } else {
            throw "Maven build failed with exit code $LASTEXITCODE"
        }
    } catch {
        Write-ErrorMsg "Build failed: $_"
        if (-not (Test-Path ".\target\finding.war")) {
            Write-ErrorMsg "No war file found in target/"
            exit 1
        } else {
            Write-Warn "Build failed but war exists, continuing..."
        }
    }
} else {
    Write-Step "[5/7] Skipping build (SkipBuild flag)"
}

# Step 6: Tomcat
Write-Step "[6/7] Setting up Tomcat 9..."
$tomcatPath = ".\tools\tomcat"
if (-not (Test-Path $tomcatPath)) {
    Write-Host "  Downloading Tomcat 9.0.85..." -ForegroundColor Yellow
    $tomcatUrl = "https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.zip"
    $zipPath = ".\tools\tomcat.zip"
    try {
        Invoke-WebRequest -Uri $tomcatUrl -OutFile $zipPath
        Expand-Archive -Path $zipPath -DestinationPath ".\tools" -Force
        $extracted = Get-ChildItem ".\tools\apache-tomcat-*" -Directory | Select-Object -First 1
        Move-Item $extracted.FullName $tomcatPath -Force
        Write-OK "Tomcat installed to $tomcatPath"
    } catch {
        Write-ErrorMsg "Failed to download Tomcat: $_"
        Start-Process "https://tomcat.apache.org/download-90.cgi"
        exit 1
    }
} else {
    Write-OK "Tomcat found: $tomcatPath"
}

Write-Host "  Deploying war..." -ForegroundColor Yellow
if (Test-Path "$tomcatPath\webapps\ROOT") { Remove-Item "$tomcatPath\webapps\ROOT" -Recurse -Force }
if (Test-Path "$tomcatPath\webapps\ROOT.war") { Remove-Item "$tomcatPath\webapps\ROOT.war" -Force }
Copy-Item ".\target\finding.war" "$tomcatPath\webapps\ROOT.war" -Force
Write-OK "War deployed to Tomcat"

Write-Host "  Initializing database..." -ForegroundColor Yellow
if ($mysqlOk) {
    try {
        Get-Content ".\sql\init.sql" | mysql -u root -ptoor project 2>&1 | Out-Null
        if ($LASTEXITCODE -ne 0) {
            Get-Content ".\sql\init.sql" | mysql -u root project 2>&1 | Out-Null
        }
        Write-OK "Database initialized with demo data"
    } catch {
        Write-Warn "DB init failed: $_"
    }
}

# Step 7: Start
Write-Step "[7/7] Starting Tomcat on port $Port..."
$env:JAVA_OPTS = "-Xms512m -Xmx1024m -XX:+UseG1GC"
$env:CATALINA_OPTS = "-Dfile.encoding=UTF-8"

try {
    Start-Process -FilePath "$tomcatPath\bin\startup.bat" -WindowStyle Minimized
    Write-Host "  Waiting 15s for Tomcat to start..." -ForegroundColor Yellow
    Start-Sleep -Seconds 15
    
    $listening = $false
    try {
        $null = Test-NetConnection -ComputerName localhost -Port $Port -WarningAction SilentlyContinue
        # Check via netstat
        $netstat = netstat -an | Select-String ":$Port" | Select-String "LISTENING"
        if ($netstat) { $listening = $true }
    } catch {}
    
    if ($listening) {
        Write-OK "Tomcat listening on port $Port"
    } else {
        Write-Warn "Tomcat may still be starting, check logs"
    }
} catch {
    Write-ErrorMsg "Failed to start Tomcat: $_"
    exit 1
}

Write-Host @"
  ================================================================
   SUCCESS! FindinG is running!
  ================================================================
    URL: http://localhost:$Port
    Health: http://localhost:$Port/health.jsp
    Demo Student: student1 / Student@123
    Demo Company: company1 / Company@123

    Tomcat Logs: tools\tomcat\logs\catalina.out
    Stop: tools\tomcat\bin\shutdown.bat
    Or: docker-compose down (if Docker)
  ================================================================
"@ -ForegroundColor Green

Start-Process "http://localhost:$Port"

Write-Host "Press Enter to view logs, or Ctrl+C to keep server running in background..." -ForegroundColor Yellow
Read-Host

if (Test-Path "$tomcatPath\logs\catalina.out") {
    Write-Host "`nLast 30 lines of Tomcat log:" -ForegroundColor Cyan
    Get-Content "$tomcatPath\logs\catalina.out" -Tail 30
}

Write-Host "`nServer running in background. To stop: .\tools\tomcat\bin\shutdown.bat" -ForegroundColor Green
