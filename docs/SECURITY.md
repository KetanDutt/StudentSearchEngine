# Security Documentation - FindinG v2.0

## Threat Model
- SQL Injection
- XSS
- Session hijacking
- Brute force
- CSRF
- Information disclosure

## Fixes Implemented

### 1. SQL Injection - CRITICAL (Fixed)
**Before**: String concatenation
```java
"select * from user where user='"+user+"'"
```
**After**: PreparedStatement
```java
ps = con.prepareStatement("SELECT ... WHERE user = ?");
ps.setString(1, username);
```

All JSPs now use PreparedStatement: login.jsp, reg.jsp, stureg.jsp, hrreg.jsp, stusearch.jsp, hrsearch.jsp.

### 2. Password Security - CRITICAL (Fixed)
**Before**: Plain text storage
**After**: BCrypt work factor 12
```java
SecurityUtil.hashPassword(pwd) // BCrypt
SecurityUtil.checkPassword(plain, hashed)
```
- Auto-upgrades legacy plain passwords on login
- Password strength enforced: 8+ chars, upper, lower, digit

### 3. XSS - HIGH (Fixed)
**Before**: Direct output `out.print(user)`
**After**: Escaped
```java
SecurityUtil.escapeHtml(rs.getString("user"))
SecurityUtil.sanitizeSearch(input)
```
- Security headers: X-Content-Type-Options nosniff, X-Frame-Options DENY, X-XSS-Protection
- JSTL escaping ready

### 4. Session Management - HIGH (Fixed)
**Before**: `session.putValue()` deprecated, no invalidation, no timeout
**After**:
```java
session.invalidate();
session = request.getSession(true);
session.setAttribute("user", username);
session.setMaxInactiveInterval(30*60);
```
- HttpOnly cookie via web.xml
- Cache-Control no-cache
- Logout invalidates and clears cookies

### 5. Input Validation - MEDIUM (Fixed)
- Client: app.js with regex, password strength, debounced
- Server: SecurityUtil.isValidUsername, isValidEmail, isStrongPassword, sanitizeSearch
- Length limits, type checks

### 6. Deprecated APIs - MEDIUM (Fixed)
- `session.putValue` → `setAttribute`
- `com.mysql.jdbc.Driver` → `com.mysql.cj.jdbc.Driver`
- jQuery 1.11.3 → Bootstrap 5 + vanilla JS

### 7. Information Disclosure - MEDIUM (Fixed)
- Custom 404/500 pages, no stack trace to user
- Errors logged server-side only
- No amazon ads http script (removed)

## Additional Hardening

### Headers (via prelude.jspf & web.xml)
```
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
X-XSS-Protection: 1; mode=block
Referrer-Policy: strict-origin-when-cross-origin
Cache-Control: no-cache for auth pages
```

### Database
- Dedicated user, not root
- Least privilege
- SSL option
- Audit log table

### Docker
- Non-root user in container
- Healthchecks
- No secrets in image

## Remaining Risks & Mitigations

| Risk | Status | Mitigation |
|------|--------|------------|
| CSRF | Partial | Add CSRF token (SecurityUtil.generateCsrfToken() ready) - TODO add to forms |
| Brute Force | TODO | Add rate limiting filter, captcha, lockout after 5 fails |
| HTTPS | Env | Use reverse proxy (nginx) with TLS in prod |
| File Upload | N/A | If adding resumes, validate MIME, scan |
| Dependency Vuln | Done | pom.xml uses latest mysql, HikariCP, jbcrypt, Bootstrap 5 CDN |

## Security Checklist for Production
- [x] PreparedStatements everywhere
- [x] BCrypt passwords
- [x] XSS escaping
- [x] Secure session
- [x] Input validation
- [x] Error pages
- [x] Remove debug info
- [ ] Enable HTTPS (nginx)
- [ ] Add rate limiting
- [ ] Add CSRF tokens to all forms
- [ ] Set secure=true for cookies when HTTPS
- [ ] Rotate DB passwords
- [ ] Enable MySQL SSL
- [ ] Regular dependency updates (`mvn versions:display-dependency-updates`)

## Reporting Vulnerabilities
Contact: ketan6196@gmail.com - please include steps to reproduce, no public disclosure before fix.

## Audit Log Usage
```java
// Example: log login
try (PreparedStatement ps = con.prepareStatement("INSERT INTO audit_log (user, action, ip_address, user_agent) VALUES (?, ?, ?, ?)")) {
  ps.setString(1, username);
  ps.setString(2, "LOGIN_SUCCESS");
  ps.setString(3, request.getRemoteAddr());
  ps.setString(4, request.getHeader("User-Agent"));
  ps.executeUpdate();
}
```
