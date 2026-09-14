# Database Documentation - FindinG v2.0

## Overview
MySQL 8.0, database name `project` (configurable via env). Uses InnoDB, utf8mb4.

## Schema

### `user` Table
Central authentication table.

| Column | Type | Notes |
|--------|------|-------|
| user | VARCHAR(50) PK | Username, alphanumeric + _ |
| pwd | VARCHAR(255) | BCrypt hash ($2a$12$...) |
| fname | VARCHAR(100) | First name |
| lname | VARCHAR(100) | Last name |
| email | VARCHAR(255) UNIQUE | Validated email |
| occ | ENUM('stu','hr') | Role |
| created_at | TIMESTAMP | Auto |
| updated_at | TIMESTAMP | Auto update |
| last_login | TIMESTAMP NULL | Updated on login |
| is_active | BOOLEAN | Soft delete |

Indexes: email unique, occ, created_at

### `student` Table
FK to user.

| Column | Type | Notes |
|--------|------|-------|
| user | PK, FK | |
| age | TINYINT | 16-60 |
| mnum | VARCHAR(15) | 10-digit |
| fname, mname | VARCHAR(100) | Father/mother |
| addr | VARCHAR(255) | |
| cid | VARCHAR(150) | College |
| uid | VARCHAR(150) | University |
| brch | VARCHAR(50) | Branch |
| sem | TINYINT | 1-8 |
| 10thb, 12thb | VARCHAR(100) | Boards (needs backticks) |
| 10thp, 12thp | VARCHAR(10) | Percentages |
| t1, t2 | VARCHAR(100) | Tech |
| c1, c2 | VARCHAR(150) | Company |
| ds1, de1, ds2, de2 | VARCHAR(50) | Duration |
| jid, ja, jt, js | VARCHAR | Job pref |

Indexes: cid, brch, t1, jid, composite (brch,cid,t1), FULLTEXT (user,cid,uid,brch,t1,t2,jid,ja)

### `company` Table
FK to user.

| Column | Notes |
|--------|-------|
| user | PK FK |
| cid | Company name |
| auth | Authorization code |
| yr | Year established |
| emp | Employees |
| hsal | Highest salary |
| brch | Branches |
| addr | Address |
| t1, c1, y1, a1 | Major product |
| t2, c2, y2, a2 | Minor product |
| jid, ja, jt, js | Major job |
| jid2, ja2, jt2, js2 | Minor job |

Indexes: cid, jid, yr, composite, FULLTEXT

### `audit_log` Table (New v2.0)
Tracks security events.

| Column | Type |
|--------|------|
| id | BIGINT AUTO_INCREMENT PK |
| user | VARCHAR(50) |
| action | VARCHAR(100) |
| ip_address | VARCHAR(45) |
| user_agent | VARCHAR(255) |
| created_at | TIMESTAMP |

## Setup

### Local MySQL
```sql
CREATE DATABASE project CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'finding_user'@'localhost' IDENTIFIED BY 'finding_pass_2026';
GRANT ALL PRIVILEGES ON project.* TO 'finding_user'@'localhost';
FLUSH PRIVILEGES;
-- Then run sql/init.sql
mysql -u root -p project < sql/init.sql
```

### Docker
```bash
docker-compose up -d mysql
# Wait healthy, then init auto-runs via /docker-entrypoint-initdb.d/
```

### Environment Variables
- DB_URL: jdbc url
- DB_USER, DB_PASSWORD

### Connection Pooling
HikariCP config in DBUtil.java:
- maxPool 10, minIdle 2
- connectionTimeout 30s
- idleTimeout 10m
- maxLifetime 30m
- leakDetection 60s
- cachePrepStmts true, cacheSize 250

## Performance Tuning
- Use `EXPLAIN` on search queries
- FULLTEXT search: `SELECT * FROM student WHERE MATCH(user,cid,uid,brch,t1,t2,jid,ja) AGAINST (? IN BOOLEAN MODE)`
  - Currently uses LIKE for compatibility, but FULLTEXT ready
- Pagination prevents OOM
- Indexes reduce full scan

## Migration from v1.0
v1.0 had:
- No FKs, no indexes, no timestamps
- Plain text passwords
- No charset specified
- No validation

Migration script:
```sql
ALTER TABLE user MODIFY pwd VARCHAR(255);
-- Then login will auto-upgrade to BCrypt
-- Add FKs, indexes as in init.sql
```

## Backup
```bash
mysqldump -u root -p project > backup.sql
# Restore
mysql -u root -p project < backup.sql
```

## Security
- No root remote login
- Use dedicated user with limited privileges
- Enable SSL in production: `?useSSL=true`
- Rotate passwords regularly
- Audit log monitors suspicious activity
