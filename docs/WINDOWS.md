# Windows One-Click Run Guide - FindinG v2.0

## Overview
This guide explains how to run FindinG on Windows with **one click**, including automatic dependency checking and installation.

## Quick Start - 3 Options

### Option 1: Easiest - Double Click `run.bat` (Recommended for Beginners)

1. **Download/Clone project**
   ```bat
   git clone https://github.com/KetanDutt/StudentSearchEngine.git
   cd StudentSearchEngine
   ```

2. **Double-click `run.bat`** in Windows Explorer

3. **Done!** Browser opens to http://localhost:8080

**What happens:**
- Checks Java 11+ → If missing, opens download page
- Checks Docker → If found, uses `docker-compose up` (MySQL + Tomcat auto)
- Checks Maven → Uses `mvnw.cmd` wrapper or downloads to `tools/maven`
- Checks MySQL → Tests connection or starts MySQL via Docker
- Builds project → `mvn clean package`
- Downloads Tomcat 9 → To `tools/tomcat` if missing
- Initializes DB → Runs `sql/init.sql` with demo data
- Starts server → Tomcat on port 8080
- Opens browser

### Option 2: PowerShell with Auto-Install (Most Automated - Recommended for Developers)

**Run as Administrator** for auto-installation of dependencies.

```powershell
# Open PowerShell as Administrator
# Navigate to project:
cd C:\path\to\StudentSearchEngine

# Auto-install dependencies + run with Docker (EASIEST):
powershell -ExecutionPolicy Bypass -File run.ps1 -InstallDeps -UseDocker

# Or just run (checks deps, doesn't auto-install):
powershell -ExecutionPolicy Bypass -File run.ps1

# Custom port:
powershell -ExecutionPolicy Bypass -File run.ps1 -Port 8081

# Skip build if already built:
powershell -ExecutionPolicy Bypass -File run.ps1 -SkipBuild
```

**Flags:**
- `-InstallDeps` - Auto-install Java, Maven, MySQL, Docker via Chocolatey/Winget
- `-UseDocker` - Force Docker deployment (recommended)
- `-SkipBuild` - Skip Maven build (use existing war)
- `-Port 8081` - Custom port

**Auto-installs via:**
- Chocolatey (`choco install temurin11 maven mysql docker-desktop -y`)
- Winget fallback (`winget install EclipseAdoptium.Temurin.11.JDK`)

### Option 3: Manual Setup + Run

```bat
# Step 1: Install dependencies (Run as Administrator)
setup.bat

# This installs:
# - Chocolatey (package manager)
# - Java 11 JDK (Temurin)
# - Maven 3.9
# - MySQL 8.0
# - Docker Desktop

# Step 2: Restart terminal/computer if Docker installed

# Step 3: Run
run.bat

# Or check environment first:
scripts\windows\check-env.bat
```

## Detailed Script Reference

### Root Scripts

| File | Description | Usage |
|------|-------------|-------|
| `run.bat` | Main one-click runner (CMD) | Double-click or `run.bat` |
| `run.ps1` | PowerShell runner with auto-install | `powershell -ExecutionPolicy Bypass -File run.ps1 -InstallDeps` |
| `setup.bat` | Install dependencies via Chocolatey | `setup.bat` (admin) |
| `run-webapp.bat` | Run webapp only (Tomcat, no Docker) | `run-webapp.bat` |
| `start.bat` | Alias to run.bat | `start.bat` |
| `mvnw.cmd` | Maven wrapper - auto-downloads Maven | `mvnw.cmd clean package` |
| `run.sh` | Linux/Mac one-click runner | `./run.sh` |

### Helper Scripts (`scripts/windows/`)

| File | Description |
|------|-------------|
| `check-env.bat` | Checks Java, Maven, MySQL, Docker, Tomcat, war file |
| `install-dependencies.bat` | Calls setup.bat |
| `start-tomcat.bat` | Starts Tomcat only (assumes war already built) |

### Tools Directory (`tools/`)

Auto-created on first run:

```
tools/
├── tomcat/          # Tomcat 9.0.85 (auto-downloaded)
├── maven/           # Maven 3.9.6 (if not globally installed)
├── tomcat.zip       # Downloaded archive (can delete)
└── maven.zip        # Downloaded archive (can delete)
```

Can be deleted anytime - will be re-downloaded on next run.

## Dependencies Explained

### Java 11+
- **Required**: Yes
- **Check**: `java -version`
- **Install**:
  - Manual: https://adoptium.net/temurin/releases/?version=11
  - Choco: `choco install temurin11 -y`
  - Winget: `winget install EclipseAdoptium.Temurin.11.JDK`
- **Auto**: `run.ps1 -InstallDeps` installs automatically

### Maven 3.8+
- **Required**: For building (unless using Docker)
- **Check**: `mvn -version`
- **Install**:
  - Manual: https://maven.apache.org/download.cgi
  - Choco: `choco install maven -y`
  - Auto: Script downloads to `tools/maven` if missing
  - Wrapper: `mvnw.cmd` included - auto-downloads Maven

### MySQL 8.0+
- **Required**: Yes for database
- **Check**: `mysql --version` and `mysql -u root -ptoor -e "SELECT 1"`
- **Install Options**:
  1. **Docker (Easiest)**: `run.bat` auto-starts MySQL container if Docker available
  2. Choco: `choco install mysql -y`
  3. Manual: https://dev.mysql.com/downloads/installer/
- **Config**: Default root/toor, or create `finding_user`/`finding_pass_2026`
- **Auto**: `run.ps1 -InstallDeps` can install, or Docker fallback

### Docker Desktop
- **Required**: No, but **highly recommended** - makes everything 1 command
- **Check**: `docker --version` and `docker-compose --version`
- **Install**:
  - Choco: `choco install docker-desktop -y`
  - Manual: https://www.docker.com/products/docker-desktop/
- **Benefits**: Auto-runs MySQL + Tomcat, no need to install MySQL/Tomcat manually
- **Usage**: If found, `run.bat` prefers Docker: `docker-compose up --build -d`

### Tomcat 9+
- **Required**: For manual deployment (not needed if using Docker)
- **Check**: `tools/tomcat/bin/startup.bat` exists
- **Install**: Auto-downloaded by `run.bat` to `tools/tomcat` from https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.zip
- **Manual**: https://tomcat.apache.org/download-90.cgi

## Step-by-Step Examples

### Example 1: Fresh Windows PC - No Dependencies

```bat
# 1. Install Git (if not installed)
# Download from https://git-scm.com/download/win

# 2. Clone project
git clone https://github.com/KetanDutt/StudentSearchEngine.git
cd StudentSearchEngine

# 3. Run setup as admin (installs Java, Maven, MySQL, Docker)
# Right-click setup.bat -> Run as Administrator
setup.bat

# 4. Restart computer if Docker was installed

# 5. Start Docker Desktop (from Start menu)

# 6. Run
run.bat

# Browser opens to http://localhost:8080
# Login with student1 / Student@123
```

### Example 2: PowerShell One-Liner - Fully Automated

```powershell
# Open PowerShell as Administrator

# Clone and run in one go:
git clone https://github.com/KetanDutt/StudentSearchEngine.git; cd StudentSearchEngine; powershell -ExecutionPolicy Bypass -File run.ps1 -InstallDeps -UseDocker

# This will:
# - Install Chocolatey if missing
# - Install Java 11, Maven, MySQL, Docker via Choco
# - Build project
# - Start via Docker
# - Open browser
```

### Example 3: Existing Java/Maven, No Docker

```bat
# If you already have Java and Maven, but no Docker/MySQL:

run.bat

# Script will:
# - Find Java and Maven
# - Try MySQL connection
# - If MySQL not found, try Docker container for MySQL
# - If Docker not found, warn but continue build
# - Download Tomcat to tools/tomcat
# - Build war
# - Deploy and start Tomcat
```

### Example 4: Docker Only (Fastest if Docker installed)

```bat
# If Docker Desktop is running:

docker-compose up --build -d

# Check:
docker-compose ps
docker-compose logs -f

# Open http://localhost:8080

# Stop:
docker-compose down
```

## Troubleshooting

### Java not found
```
[ERROR] Java not found!
```
**Fix:**
- Install Java 11: https://adoptium.net/temurin/releases/?version=11
- Or: `choco install temurin11 -y`
- Or: `winget install EclipseAdoptium.Temurin.11.JDK`
- Ensure `JAVA_HOME` set and `java` in PATH
- Restart terminal after install

### Maven not found
```
[WARN] Maven not found
```
**Fix:**
- Script auto-downloads to `tools/maven` - wait for download
- Or install: `choco install maven -y`
- Or use wrapper: `mvnw.cmd clean package` (included)
- Ensure `mvn` in PATH

### MySQL connection failed
```
[WARN] MySQL not available
```
**Fix Options:**
1. **Use Docker (Easiest)**: Install Docker Desktop, run `run.bat` - it auto-starts MySQL container
2. **Install MySQL**: `choco install mysql -y`, then set root password to `toor` or update `config.properties`
3. **Manual**: Install from https://dev.mysql.com/downloads/installer/, create DB `project`, run `sql/init.sql`
4. **Check service**: `services.msc` -> MySQL -> Start

### Port 8080 in use
```
[WARN] Tomcat may still be starting
# Or: Address already in use
```
**Fix:**
- Find process: `netstat -ano | findstr :8080`
- Kill: `taskkill /PID <pid> /F`
- Or use different port: `run.ps1 -Port 8081`
- Or change in `tools/tomcat/conf/server.xml`: `<Connector port="8081"`

### Tomcat fails to start
- Check logs: `tools/tomcat/logs/catalina.out` and `catalina.*.log`
- Check Java version: `java -version` must be 11+
- Check war exists: `dir target\finding.war`
- Try: `tools\tomcat\bin\shutdown.bat` then `startup.bat`
- Check antivirus blocking

### Docker not starting
- Ensure Docker Desktop is running (icon in system tray)
- Restart Docker Desktop
- Restart computer after Docker install
- Check WSL2 installed (required for Docker Desktop)
- Try: `docker --version` and `docker ps`

### Build fails
```
[ERROR] Build failed!
```
- Check Java 11+ installed
- Check internet connection (needs to download dependencies)
- Check logs above error
- Try: `mvn clean package -X` for debug
- Delete `target/` and retry
- Check `pom.xml` exists

### Browser doesn't open
- Manually open http://localhost:8080
- Check Tomcat started: `netstat -an | findstr :8080`
- Check logs: `tools\tomcat\logs\catalina.out`
- Wait 30 seconds after start

## Performance Tips

- **Use Docker**: Fastest, most reliable, auto-manages MySQL
- **Use SSD**: Build and Tomcat startup faster
- **Allocate RAM**: Docker Desktop -> Settings -> Resources -> Memory 4GB+
- **Java Opts**: Script sets `-Xms512m -Xmx1024m -XX:+UseG1GC` automatically

## Security for Production on Windows

- Change DB password from `toor` to strong password in `.env` and `config.properties`
- Enable MySQL SSL
- Use nginx as reverse proxy with TLS
- Set `secure=true` in `WEB-INF/web.xml` cookie-config when using HTTPS
- Don't expose MySQL port 3306 publicly

## Uninstall / Cleanup

```bat
# Stop Tomcat
tools\tomcat\bin\shutdown.bat

# Stop Docker containers
docker-compose down
docker rm -f finding_mysql_temp

# Delete tools (will re-download on next run)
rmdir /s /q tools

# Delete build
rmdir /s /q target

# Delete MySQL data (Docker)
docker volume rm studentsearchengine_mysql_data
```

## Getting Help

- Check `scripts/windows/check-env.bat` for environment status
- Check logs: `tools/tomcat/logs/catalina.out` or `docker-compose logs -f`
- Check health: http://localhost:8080/health.jsp
- Open issue on GitHub with logs
- Email: ketan6196@gmail.com

## Video Guide (Conceptual)

1. Download project ZIP or `git clone`
2. Right-click `run.bat` -> Run as Administrator (first time)
3. Wait for auto-setup (Java, Maven, Tomcat download)
4. Browser opens automatically
5. Login with demo accounts

That's it! One click!
