# API Documentation - FindinG v2.0

## Overview
Currently server-rendered JSP, but designed for REST migration. This doc describes current endpoints and future REST API.

## Current Endpoints (JSP)

### Authentication

#### POST /login.jsp
Login user.

**Request**:
- `usr`: username (3-50 chars)
- `pwd`: password

**Response**:
- 302 Redirect to `stu.html` or `hr.html` if profile exists, else `stureg.html`/`hrreg.html`
- 302 to `index.html?error=invalid` on failure

**Security**: PreparedStatement, BCrypt check, session fixation protection

#### POST /reg.jsp
Register new user.

**Request**:
- `userid`: username (alphanumeric + _ , 3-30)
- `pwd`: password (8+ chars, upper, lower, digit)
- `fname`, `lname`: names
- `email`: valid email
- `occ`: `stu` or `hr`

**Response**:
- Alert + redirect to profile form on success
- Alert + back on validation fail
- Checks duplicate username/email

#### GET /logout.jsp
Logout, invalidate session, clear cookies, redirect to index.

### Profile

#### POST /stureg.jsp
Create/update student profile. Requires session.

**Request**: All student fields (see DATABASE.md)
- `user`: must match session user
- `cid`, `brch`, `sem`: required
- Others optional

**Response**: Alert + redirect to `stu.html`

**Logic**: Upsert - UPDATE if exists else INSERT

#### POST /hrreg.jsp
Create/update company profile. Requires session.

**Request**: Company fields
- `user`: must match session
- `cid`: required

**Response**: Alert + redirect to `hr.html`

### Search

#### POST /stusearch.jsp (HR searches students)
Requires session.

**Request**:
- `search`: search term (sanitized, max 100 chars)
- `page`: optional page number (default 1)

**Response**: HTML table with results, pagination

**Query**: Searches 26 columns with LIKE %term% using PreparedStatement, LIMIT 20 OFFSET

#### POST /hrsearch.jsp (Students search companies)
Requires session.

**Request**: same as above

**Response**: HTML table, 14 columns, pagination

**Query**: 24 columns

## Future REST API (Roadmap)

### Proposed Endpoints

```
POST /api/v1/auth/register
POST /api/v1/auth/login
POST /api/v1/auth/logout
GET  /api/v1/auth/me

GET  /api/v1/students?search=&page=&branch=&college=
GET  /api/v1/students/{username}
POST /api/v1/students
PUT  /api/v1/students/{username}

GET  /api/v1/companies?search=&page=
GET  /api/v1/companies/{username}
POST /api/v1/companies
PUT  /api/v1/companies/{username}

GET  /api/v1/health
```

### Example REST Response
```json
{
  "success": true,
  "data": {
    "user": "student1",
    "college": "PIET",
    "branch": "CSE",
    "skills": ["Java", "Python"],
    "jobPreference": {
      "role": "Software Engineer",
      "location": "Bangalore",
      "salary": "8 LPA"
    }
  },
  "meta": {
    "page": 1,
    "pageSize": 20,
    "total": 150
  }
}
```

### Error Format
```json
{
  "success": false,
  "error": {
    "code": "INVALID_CREDENTIALS",
    "message": "Username or password incorrect"
  }
}
```

## Security for API
- JWT Bearer token (future)
- Rate limiting: 100 req/min per IP
- CORS: whitelist domains
- Validation: same as JSP

## Pagination
- `page`: 1-indexed
- `pageSize`: 20 (fixed for now, configurable via config.properties)
- Response includes `hasNext`, `hasPrev`

## Search Syntax (Current)
- Simple substring LIKE search across all columns
- Future: support filters `?branch=CSE&college=PIET&skill=Java`

## Code Examples

### JavaScript Fetch (Future REST)
```javascript
// Login
const res = await fetch('/api/v1/auth/login', {
  method: 'POST',
  headers: {'Content-Type': 'application/json'},
  body: JSON.stringify({user: 'student1', pwd: 'Student@123'})
});
const data = await res.json();

// Search
const searchRes = await fetch('/api/v1/students?search=Java&page=1');
const students = await searchRes.json();
```

### cURL
```bash
# Login (current JSP, form-encoded)
curl -X POST http://localhost:8080/login.jsp -d "usr=student1&pwd=Student@123" -c cookies.txt

# Search (with session)
curl -X POST http://localhost:8080/stusearch.jsp -d "search=Java" -b cookies.txt
```

## Rate Limiting (TODO)
Implement filter:
```java
@WebFilter("/api/*")
public class RateLimitFilter implements Filter {
  // Use ConcurrentHashMap IP -> count, reset every minute
}
```

## Versioning
- Current: v1 via JSP
- Future: /api/v1/, /api/v2/ for breaking changes
