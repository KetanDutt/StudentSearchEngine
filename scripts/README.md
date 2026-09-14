# Scripts Directory

This directory contains helper scripts for running FindinG on different platforms.

## Windows

### One-Click Runners (Root Directory)

- **`run.bat`** - Main one-click runner for Windows CMD
  - Checks Java, Docker, Maven, MySQL
  - Prefers Docker (easiest), falls back to manual Tomcat
  - Auto-downloads Maven & Tomcat if missing
  - Builds project and starts server
  - Opens browser to http://localhost:8080

- **`run.ps1`** - PowerShell version with auto-installation
  - More robust, can auto-install dependencies via Chocolatey/Winget
  - Supports flags: `-UseDocker`, `-SkipBuild`, `-InstallDeps`, `-Port 8080`
  - Example: `powershell -ExecutionPolicy Bypass -File run.ps1 -InstallDeps -UseDocker`

- **`setup.bat`** - Installs dependencies via Chocolatey
  - Java 11, Maven, MySQL, Docker Desktop
  - Requires admin privileges

- **`start.bat`** - Alias to `run.bat`

### Windows Helper Scripts (`scripts/windows/`)

- **`check-env.bat`** - Checks environment (Java, Maven, MySQL, Docker, Tomcat, build)
- **`install-dependencies.bat`** - Calls setup.bat
- **`start-tomcat.bat`** - Starts Tomcat only (assumes already built)

## Linux/Mac

- **`run.sh`** - One-click runner for Linux/Mac
  - Same logic as Windows version
  - Supports Docker or manual Tomcat
  - Usage: `chmod +x run.sh && ./run.sh`

## Usage Examples

### Windows - Easiest (Docker)

```bat
# Double-click run.bat or in CMD:
run.bat

# Or PowerShell with auto-install:
powershell -ExecutionPolicy Bypass -File run.ps1 -InstallDeps -UseDocker
```

### Windows - Manual (No Docker)

```bat
# Will auto-download Tomcat and Maven if missing
run.bat

# Or step by step:
setup.bat          # Install dependencies (admin)
scripts\windows\check-env.bat  # Check env
mvn clean package  # Build
scripts\windows\start-tomcat.bat  # Start
```

### Linux/Mac

```bash
chmod +x run.sh
./run.sh

# Or with Docker:
docker-compose up --build -d
```

## Troubleshooting

### Java not found
- Install from https://adoptium.net/temurin/releases/?version=11
- Or: `choco install temurin11 -y` (Windows)
- Or: `winget install EclipseAdoptium.Temurin.11.JDK`

### Maven not found
- Script auto-downloads to `tools/maven`
- Or install: `choco install maven -y`

### MySQL not found
- Easiest: Use Docker (script will auto-start MySQL container)
- Or install: `choco install mysql -y`
- Or download: https://dev.mysql.com/downloads/installer/

### Port 8080 in use
- Change port in script: `run.ps1 -Port 8081`
- Or kill process: `netstat -ano | findstr :8080` then `taskkill /PID <pid> /F`

### Tomcat fails to start
- Check logs: `tools/tomcat/logs/catalina.out`
- Check Java version (need 11+)
- Check port availability

## Tools Directory

`tools/` is auto-created:
- `tools/tomcat/` - Tomcat 9 installation
- `tools/maven/` - Maven installation (if not globally installed)
- `tools/*.zip` - Downloaded archives

Can be deleted anytime - will be re-downloaded on next run.
