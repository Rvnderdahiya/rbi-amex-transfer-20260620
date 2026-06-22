@echo off
setlocal
cd /d "%~dp0"
powershell -NoProfile -ExecutionPolicy Bypass -File "%~dp0reassemble_and_verify_browser_download.ps1"
echo.
pause
