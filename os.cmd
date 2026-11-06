@echo off
rem Runs os.ps1 for this one process, so no system setting has to change.
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0os.ps1" %*
exit /b %ERRORLEVEL%
