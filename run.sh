#!/bin/bash

# FindinG - One Click Runner for Linux/Mac v2.0
# Production Ready

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${MAGENTA}"
echo "  ================================================================"
echo "   FindinG - Student Search Engine v2.0"
echo "   One-Click Linux/Mac Runner | Production Ready"
echo "  ================================================================"
echo -e "${NC}"

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

mkdir -p tools logs target

echo -e "${CYAN}[1/7] Checking Java...${NC}"
if command -v java &> /dev/null; then
    JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2 | cut -d'.' -f1)
    echo -e "${GREEN}  [OK] Java found: $(java -version 2>&1 | head -n 1)${NC}"
    if [ "$JAVA_VERSION" -lt 11 ] 2>/dev/null; then
        echo -e "${YELLOW}  [WARN] Java $JAVA_VERSION found but need 11+${NC}"
    fi
else
    echo -e "${RED}  [ERROR] Java not found!${NC}"
    echo "  Please install Java 11:"
    echo "    Ubuntu/Debian: sudo apt install openjdk-11-jdk"
    echo "    Mac: brew install openjdk@11"
    echo "    Or download: https://adoptium.net/temurin/releases/?version=11"
    exit 1
fi

echo -e "${CYAN}[2/7] Checking Docker...${NC}"
if command -v docker &> /dev/null; then
    echo -e "${GREEN}  [OK] Docker found: $(docker --version)${NC}"
    if command -v docker-compose &> /dev/null || docker compose version &> /dev/null; then
        echo -e "${GREEN}  [OK] Docker Compose found${NC}"
        echo -e "${YELLOW}  [INFO] Docker deployment is EASIEST${NC}"
        read -p "  Use Docker? (Y/n): " choice
        if [[ "$choice" == "" || "$choice" =~ ^[Yy] ]]; then
            echo -e "${CYAN}  Starting with Docker Compose...${NC}"
            if command -v docker-compose &> /dev/null; then
                docker-compose up --build -d
                docker-compose ps
            else
                docker compose up --build -d
                docker compose ps
            fi
            echo -e "${GREEN}"
            echo "  ================================================================"
            echo "   SUCCESS! Application running via Docker"
            echo "  ================================================================"
            echo "    URL: http://localhost:8080"
            echo "    Health: http://localhost:8080/health.jsp"
            echo "    Demo Student: student1 / Student@123"
            echo "    Demo Company: company1 / Company@123"
            echo "  ================================================================"
            echo -e "${NC}"
            if command -v xdg-open &> /dev/null; then
                xdg-open http://localhost:8080
            elif command -v open &> /dev/null; then
                open http://localhost:8080
            fi
            exit 0
        fi
    fi
else
    echo -e "${YELLOW}  [INFO] Docker not found - Using manual Tomcat${NC}"
fi

echo -e "${CYAN}[3/7] Checking Maven...${NC}"
MVN_CMD=""
if [ -f "./mvnw" ]; then
    MVN_CMD="./mvnw"
    echo -e "${GREEN}  [OK] Maven Wrapper found: mvnw${NC}"
    chmod +x ./mvnw
elif command -v mvn &> /dev/null; then
    MVN_CMD="mvn"
    echo -e "${GREEN}  [OK] Maven found: $(mvn --version | head -n 1)${NC}"
else
    echo -e "${YELLOW}  [WARN] Maven not found, downloading...${NC}"
    mkdir -p tools/maven
    MAVEN_URL="https://archive.apache.org/dist/maven/maven-3/3.9.6/binaries/apache-maven-3.9.6-bin.tar.gz"
    echo "  Downloading Maven from $MAVEN_URL"
    if command -v wget &> /dev/null; then
        wget -q "$MAVEN_URL" -O tools/maven.tar.gz
    elif command -v curl &> /dev/null; then
        curl -sL "$MAVEN_URL" -o tools/maven.tar.gz
    else
        echo -e "${RED}  [ERROR] Need wget or curl to download Maven${NC}"
        exit 1
    fi
    tar -xzf tools/maven.tar.gz -C tools/
    MAVEN_HOME=$(find tools -type d -name "apache-maven-*" | head -n 1)
    MVN_CMD="$MAVEN_HOME/bin/mvn"
    echo -e "${GREEN}  [OK] Maven installed to $MAVEN_HOME${NC}"
fi

echo -e "${CYAN}[4/7] Checking MySQL...${NC}"
MYSQL_OK=0
if command -v mysql &> /dev/null; then
    echo -e "${GREEN}  [OK] MySQL client found${NC}"
    if mysql -u root -ptoor -e "SELECT 1" &> /dev/null; then
        echo -e "${GREEN}  [OK] MySQL connection OK (root/toor)${NC}"
        MYSQL_OK=1
    elif mysql -u root -e "SELECT 1" &> /dev/null; then
        echo -e "${GREEN}  [OK] MySQL connection OK (root no password)${NC}"
        mysql -u root -e "CREATE DATABASE IF NOT EXISTS project CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci; CREATE USER IF NOT EXISTS 'finding_user'@'localhost' IDENTIFIED BY 'finding_pass_2026'; GRANT ALL ON project.* TO 'finding_user'@'localhost'; FLUSH PRIVILEGES;" &> /dev/null
        MYSQL_OK=1
    else
        echo -e "${YELLOW}  [WARN] MySQL running but auth failed${NC}"
    fi
else
    echo -e "${YELLOW}  [WARN] MySQL not found${NC}"
fi

if [ $MYSQL_OK -eq 0 ] && command -v docker &> /dev/null; then
    echo -e "${YELLOW}  Starting MySQL via Docker...${NC}"
    docker run -d --name finding_mysql_temp -e MYSQL_ROOT_PASSWORD=toor -e MYSQL_DATABASE=project -p 3306:3306 mysql:8.0 &> /dev/null || true
    echo "  Waiting 20s for MySQL..."
    sleep 20
    MYSQL_OK=1
fi

echo -e "${CYAN}[5/7] Building project...${NC}"
echo "  Running: $MVN_CMD clean package -DskipTests"
$MVN_CMD clean package -DskipTests
if [ $? -ne 0 ]; then
    echo -e "${RED}  [ERROR] Build failed!${NC}"
    if [ ! -f "target/finding.war" ]; then
        echo -e "${RED}  [ERROR] No war file in target/${NC}"
        exit 1
    fi
else
    echo -e "${GREEN}  [OK] Build successful!${NC}"
fi

echo -e "${CYAN}[6/7] Setting up Tomcat...${NC}"
TOMCAT_PATH="./tools/tomcat"
if [ ! -d "$TOMCAT_PATH" ]; then
    echo "  Downloading Tomcat 9.0.85..."
    TOMCAT_URL="https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.85/bin/apache-tomcat-9.0.85.tar.gz"
    if command -v wget &> /dev/null; then
        wget -q "$TOMCAT_URL" -O tools/tomcat.tar.gz
    else
        curl -sL "$TOMCAT_URL" -o tools/tomcat.tar.gz
    fi
    tar -xzf tools/tomcat.tar.gz -C tools/
    EXTRACTED=$(find tools -type d -name "apache-tomcat-*" | head -n 1)
    mv "$EXTRACTED" "$TOMCAT_PATH"
    echo -e "${GREEN}  [OK] Tomcat installed to $TOMCAT_PATH${NC}"
else
    echo -e "${GREEN}  [OK] Tomcat found: $TOMCAT_PATH${NC}"
fi

echo "  Deploying war..."
rm -rf "$TOMCAT_PATH/webapps/ROOT" "$TOMCAT_PATH/webapps/ROOT.war"
cp "target/finding.war" "$TOMCAT_PATH/webapps/ROOT.war"
echo -e "${GREEN}  [OK] War deployed${NC}"

if [ $MYSQL_OK -eq 1 ]; then
    echo "  Initializing database..."
    if mysql -u root -ptoor project < sql/init.sql &> /dev/null; then
        echo -e "${GREEN}  [OK] DB initialized${NC}"
    elif mysql -u root project < sql/init.sql &> /dev/null; then
        echo -e "${GREEN}  [OK] DB initialized${NC}"
    else
        echo -e "${YELLOW}  [WARN] DB init failed${NC}"
    fi
fi

echo -e "${CYAN}[7/7] Starting Tomcat...${NC}"
export JAVA_OPTS="-Xms512m -Xmx1024m -XX:+UseG1GC"
chmod +x "$TOMCAT_PATH/bin/"*.sh
"$TOMCAT_PATH/bin/startup.sh"

echo "  Waiting 15s for Tomcat to start..."
sleep 15

if netstat -tuln 2>/dev/null | grep -q ":8080" || ss -tuln 2>/dev/null | grep -q ":8080" || lsof -i :8080 &> /dev/null; then
    echo -e "${GREEN}  [OK] Tomcat listening on port 8080${NC}"
else
    echo -e "${YELLOW}  [WARN] Tomcat may still be starting${NC}"
fi

echo -e "${GREEN}"
echo "  ================================================================"
echo "   SUCCESS! FindinG is running!"
echo "  ================================================================"
echo "    URL: http://localhost:8080"
echo "    Health: http://localhost:8080/health.jsp"
echo "    Demo Student: student1 / Student@123"
echo "    Demo Company: company1 / Company@123"
echo ""
echo "    Logs: $TOMCAT_PATH/logs/catalina.out"
echo "    Stop: $TOMCAT_PATH/bin/shutdown.sh"
echo "  ================================================================"
echo -e "${NC}"

if command -v xdg-open &> /dev/null; then
    xdg-open http://localhost:8080
elif command -v open &> /dev/null; then
    open http://localhost:8080
fi

echo "Press Enter to view logs..."
read

if [ -f "$TOMCAT_PATH/logs/catalina.out" ]; then
    echo "Last 30 lines of log:"
    tail -n 30 "$TOMCAT_PATH/logs/catalina.out"
fi

echo -e "${GREEN}Server running in background. To stop: $TOMCAT_PATH/bin/shutdown.sh${NC}"
