# Tools Directory

This directory is auto-created and populated by `run.bat` / `run.ps1`.

## Contents (auto-downloaded)

- `tomcat/` - Apache Tomcat 9.0.85 (downloaded on first run)
- `maven/` - Maven 3.9.6 (if not installed system-wide)
- `maven.zip`, `tomcat.zip` - Downloaded archives (can be deleted after extraction)

## Purpose

Allows one-click run without requiring manual installation of Tomcat/Maven.

- If you have Maven installed globally, wrapper will use it
- If not, script downloads Maven to `tools/maven`
- Tomcat is always downloaded to `tools/tomcat` for self-contained deployment

## Manual Cleanup

You can delete this folder anytime - `run.bat` will re-download on next run.

```bat
rmdir /s /q tools
```

## Custom Tomcat

If you have existing Tomcat installation, you can:

1. Set `CATALINA_HOME` environment variable
2. Or copy your Tomcat to `tools/tomcat`
3. Or edit `run.bat` to use your path

## Logs

Tomcat logs are in `tools/tomcat/logs/`:
- `catalina.out` - Main log
- `localhost.*.log` - App logs
