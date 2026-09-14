# Setup Guide - FindinG v2.0

## Prerequisites
- Java 11+
- MySQL 8.0+
- Maven 3.8+
- Tomcat 9+ (or Docker)
- Git

## Quick Start with Docker (Recommended)

```bash
# Clone
git clone https://github.com/KetanDutt/StudentSearchEngine.git
cd StudentSearchEngine

# Copy env
cp .env.example .env
# Edit .env if needed

# Build and run full stack
docker-compose up --build -d

# Check logs
docker-compose logs -f

# App: http://localhost:8080
# MySQL: localhost:3306

# Demo accounts:
# student1 / Student@123
# company1 / Company@123
```

## Manual Setup

### 1. Database
```bash
mysql -u root -p
CREATE DATABASE project CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'finding_user'@'localhost' IDENTIFIED BY 'finding_pass_2026';
GRANT ALL ON project.* TO 'finding_user'@'localhost';
FLUSH PRIVILEGES;
EXIT;

mysql -u root -p project < sql/init.sql
```

### 2. Configure
Edit `src/main/resources/config.properties` or set env:
```bash
export DB_URL="jdbc:mysql://localhost:3306/project?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC"
export DB_USER="finding_user"
export DB_PASSWORD="finding_pass_2026"
```

### 3. Build
```bash
mvn clean package
# Output: target/finding.war
```

### 4. Deploy to Tomcat
```bash
# Copy war to tomcat webapps
cp target/finding.war $TOMCAT_HOME/webapps/ROOT.war

# Start tomcat
$TOMCAT_HOME/bin/startup.sh

# App: http://localhost:8080/
```

### 5. Development Mode (Tomcat from IDE)
- Import as Maven project in IntelliJ/Eclipse
- Configure Tomcat server
- Set artifact: finding:war exploded
- Run

## Project Structure for IDE
- Mark `src/main/java` as sources root
- Mark `src/main/resources` as resources root
- Add Tomcat library
- Ensure MySQL connector is in classpath (Maven will fetch)

## Testing
```bash
mvn test
# Or manual:
# 1. Register new user at /register.html
# 2. Login at /index.html
# 3. Complete profile
# 4. Search
```

## Environment Variables
| Var | Default | Description |
|-----|---------|-------------|
| DB_URL | jdbc:mysql://localhost:3306/project | JDBC URL |
| DB_USER | root | DB user |
| DB_PASSWORD | toor | DB pass |
| DB_POOL_SIZE | 10 | Hikari pool size |

## Troubleshooting

### MySQL connection fails
- Check MySQL running: `systemctl status mysql`
- Check credentials in config.properties
- Check firewall: `telnet localhost 3306`
- Check MySQL logs: `docker-compose logs mysql`

### Tomcat 404
- Check war deployed: `ls $TOMCAT/webapps/`
- Check logs: `$TOMCAT/logs/catalina.out`
- Check context path: should be ROOT.war for /

### BCrypt errors
- Ensure jbcrypt 0.4 jar in classpath
- Maven: `mvn dependency:tree | grep bcrypt`

### Session expired loop
- Clear cookies
- Check web.xml session timeout
- Check AuthFilter mapping

### Search returns no results
- Check data exists: `SELECT * FROM student LIMIT 5;`
- Check LIKE pattern escaping
- Try empty search to list all

## Production Deployment Checklist
- [ ] Use strong DB password, not toor
- [ ] Enable MySQL SSL
- [ ] Set secure cookie true in web.xml when HTTPS
- [ ] Put nginx in front with TLS
- [ ] Set APP_ENV=production
- [ ] Enable access logs
- [ ] Setup backup cron for MySQL
- [ ] Monitor with audit_log
- [ ] Update dependencies regularly

## Upgrading from v1.0
1. Backup DB: `mysqldump project > backup.sql`
2. Run new `sql/init.sql` (it has DROP IF EXISTS, but backup first!)
3. Or manually add new columns: `ALTER TABLE user ADD created_at...`
4. Deploy new war
5. Existing plain passwords will auto-upgrade on next login
