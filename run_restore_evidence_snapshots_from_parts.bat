@echo off
setlocal
cd /d "%~dp0"
if "%EVIDENCE_OUTPUT_DIR%"=="" (
  python restore_evidence_snapshots_from_parts.py
) else (
  python restore_evidence_snapshots_from_parts.py --output-dir "%EVIDENCE_OUTPUT_DIR%"
)
if errorlevel 1 (
  echo.
  echo Restore failed. Please share the error message shown above.
  exit /b 1
)
echo.
echo Evidence snapshots restored and validated successfully.
exit /b 0
