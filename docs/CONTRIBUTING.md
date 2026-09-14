# Contributing Guide

## Code Style
- Java: Google Java Style, 4 spaces, UTF-8
- HTML/CSS/JS: 2 spaces, semantic HTML, BEM for CSS
- Use SecurityUtil for all user input
- Use DBUtil.getConnection() not DriverManager
- Always use PreparedStatement

## Branching
- `master`: production
- `feature/*`: new features
- `fix/*`: bug fixes
- PR to master with description

## Commit Messages
- feat: new feature
- fix: bug fix
- docs: documentation
- style: formatting
- refactor: code refactor
- perf: performance
- sec: security fix
- Example: `sec: fix SQL injection in login.jsp using PreparedStatement`

## Pull Request Checklist
- [ ] No SQL concatenation
- [ ] BCrypt for passwords
- [ ] XSS escaping
- [ ] Server-side validation
- [ ] Resource closing in finally
- [ ] Updated docs
- [ ] Tested manually
- [ ] No secrets committed

## Development Setup
See SETUP.md

## Testing
- Manual test: register, login, profile, search
- Check logs for errors
- Test SQL injection: `' OR '1'='1` should not bypass login
- Test XSS: `<script>alert(1)</script>` should be escaped

## Reporting Bugs
Include:
- Steps to reproduce
- Expected vs actual
- Logs
- Screenshots

## Security Reports
Email privately: ketan6196@gmail.com, do not open public issue for critical vuln.

## License
By contributing, you agree to same license as project. No AI/ML training without permission.
