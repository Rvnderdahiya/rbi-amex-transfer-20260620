@echo off
setlocal

set "SCRIPT_DIR=%~dp0"
set "PY_SCRIPT=%SCRIPT_DIR%create_amex_pdf_buckets.py"

if not exist "%PY_SCRIPT%" (
  echo ERROR: Could not find create_amex_pdf_buckets.py in:
  echo %SCRIPT_DIR%
  pause
  exit /b 2
)

where py >nul 2>nul
if %errorlevel%==0 (
  py -3 "%PY_SCRIPT%"
  pause
  exit /b %errorlevel%
)

where python >nul 2>nul
if %errorlevel%==0 (
  python "%PY_SCRIPT%"
  pause
  exit /b %errorlevel%
)

echo ERROR: Python was not found on this machine.
echo Please install/enable Python, or run this script from a Python-enabled terminal.
pause
exit /b 2
