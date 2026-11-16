@echo off
rem Launcher for Google's Modern Web Guidance tool, set up for Tom's Skills OS.
rem   - Pins the version, so the tool only changes when the number below changes.
rem   - Switches off usage reporting to Google (search queries and guide IDs).
rem   - Uses the copy already saved on this PC and goes online only if it is missing.
rem To update: change the number on the MWG_VERSION line, run a search, then commit.
setlocal
set "DISABLE_TELEMETRY=1"
if not defined MWG_VERSION set "MWG_VERSION=1.0.1"

for %%C in (install uninstall update) do if /i "%~1"=="%%C" goto blocked

rem npx.cmd must be called by its full path. Called by name alone, it looks for
rem its own files in the current folder and fails.
set "MWG_NPX="
for %%I in (npx.cmd) do set "MWG_NPX=%%~$PATH:I"
if not defined MWG_NPX set "MWG_NPX=%LOCALAPPDATA%\Programs\nodejs\npx.cmd"
if not exist "%MWG_NPX%" goto nonode

call "%MWG_NPX%" --prefer-offline -y modern-web-guidance@%MWG_VERSION% %*
exit /b %ERRORLEVEL%

:nonode
echo mwg: Node.js was not found. This tool needs Node.js 22 or later. 1>&2
exit /b 3

:blocked
echo mwg: "%~1" is switched off in this launcher. It would add Google's own copy of the skill, which reports usage and follows the newest release. 1>&2
echo mwg: To update, change MWG_VERSION in this file instead. 1>&2
exit /b 2
