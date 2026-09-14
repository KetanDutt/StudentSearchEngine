# Architecture - FindinG v2.0

## Overview
FindinG is a Student-Company Search Engine connecting talent with opportunities. v2.0 is a complete production-ready overhaul of the original 2015 JSP project.

## Stack
- **Frontend**: HTML5, CSS3 (modern glassmorphism), Bootstrap 5.3, Vanilla JS (ES6+)
- **Backend**: Java 11, JSP, Servlets, JSTL
- **Database**: MySQL 8.0 with HikariCP pooling
- **Security**: jBCrypt, PreparedStatements, XSS escaping, secure sessions
- **Build**: Maven, Docker, docker-compose
- **Server**: Apache Tomcat 9

## Project Structure
```
StudentSearchEngine/
├── css/
│   ├── style.css          # Modern production CSS (glassmorphism, animations)
│   ├── bootstrap.css      # Shim for backward compat
│   └── index.css          # Shim
├── js/
│   └── app.js             # Modern ES6+ validation, UI enhancements
├── images/
│   ├── logo.png
│   └── logo.ico
├── src/main/java/com/finding/
│   ├── util/
│   │   ├── DBUtil.java    # HikariCP connection pooling
│   │   └── SecurityUtil.java # BCrypt, validation, sanitization
│   ├── filter/
│   │   └── AuthFilter.java # Session auth filter
│   ├── AppInitializer.java # Startup hook
│   └── EmbeddedRunner.java # One-click webapp runner
├── src/main/resources/
│   └── config.properties  # DB config with env overrides
├── WEB-INF/
│   ├── web.xml            # Servlet config, error pages, session
│   └── jsp/prelude.jspf   # Security headers, JSTL
├── sql/
│   └── init.sql           # Optimized schema with indexes, FKs, demo data
├── docs/                  # Documentation (8 files)
├── error/
│   ├── 404.html
│   └── 500.html
├── scripts/
│   ├── README.md
│   └── windows/
│       ├── check-env.bat
│       ├── install-dependencies.bat
│       └── start-tomcat.bat
├── tools/                 # Auto-created (Tomcat, Maven)
├── run.bat                # Windows one-click CMD runner
├── run.ps1                # PowerShell runner with auto-install
├── setup.bat              # Windows dependency installer
├── run-webapp.bat         # WebApp only runner (no Docker)
├── start.bat              # Alias to run.bat
├── run.sh                 # Linux/Mac one-click runner
├── mvnw.cmd               # Maven wrapper
├── *.html                 # Modernized UI pages
├── *.jsp                  # Secured backend with PreparedStatements
├── pom.xml                # Maven build
├── Dockerfile             # Production container
├── docker-compose.yml     # Full stack
└── .env.example
```

## Data Flow
1. **Registration**: `register.html` → `reg.jsp` (validate, BCrypt hash, PreparedStatement insert) → session → profile form
2. **Login**: `index.html` → `login.jsp` (PreparedStatement select, BCrypt check, upgrade legacy pwd, session) → dashboard (stu.html/hr.html) or profile
3. **Profile**: `stureg.html/hrreg.html` → `stureg.jsp/hrreg.jsp` (upsert with PreparedStatement, sanitize) → dashboard
4. **Search**: Dashboard → `stusearch.jsp/hrsearch.jsp` (sanitize input, PreparedStatement LIKE with pagination) → results table

## Database Design (Optimized)
- **user**: PK user, unique email, occ enum, BCrypt pwd (255), timestamps, indexes
- **student**: FK user, personal/edu/tech/job fields, FULLTEXT index, composite indexes, backtick for `10thb` etc
- **company**: FK user, company/product/job fields, FULLTEXT index
- **audit_log**: New - tracks actions for security

Key improvements:
- Foreign keys with CASCADE
- Indexes on search columns
- FULLTEXT for faster search
- utf8mb4 charset
- Timestamps

## Security Architecture
- **SQL Injection**: All queries use PreparedStatement, no concatenation
- **Password**: BCrypt work factor 12, legacy upgrade path
- **XSS**: escapeHtml() on output, sanitization on input, CSP headers
- **Session**: invalidate old, HttpOnly cookie, 30min timeout, secure headers
- **Validation**: Both client (JS) and server (Java) validation
- **Headers**: X-Content-Type-Options, X-Frame-Options, XSS-Protection

## Performance Optimizations
- **Connection Pooling**: HikariCP (max 10, minIdle 2, prep stmt cache)
- **Pagination**: LIMIT/OFFSET, 20 per page, prevents full table scan
- **Indexes**: BTREE + FULLTEXT on search columns
- **Caching**: Cache-Control headers, prep stmt cache
- **Frontend**: Bootstrap CDN, minimal CSS (9KB vs 147KB), debounced search, lazy animations
- **Docker**: Multi-stage build, non-root user, healthchecks

## Scalability
- Stateless JSPs (session in cookie)
- Pooling allows horizontal scaling behind LB
- FULLTEXT search can be replaced with Elasticsearch later
- Audit log for monitoring

## Future Improvements (Roadmap)
- Migrate to Spring Boot + REST API + React
- JWT instead of session
- Elasticsearch for search
- S3 for resume uploads
- WebSocket for notifications
- Unit tests (JUnit 5 scaffold in pom.xml)
