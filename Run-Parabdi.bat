@echo off
REM ============================================================================
REM Run-Parabdi.bat - Double-click launcher for permanent IP-independent dev.
REM Runs run_parabdi.ps1: ADB detect -> adb reverse -> backend (if needed)
REM -> flutter run on the detected Android phone. No manual IP, no
REM --dart-define, no manual adb reverse, no router changes, no device ID.
REM ============================================================================
setlocal
cd /d "%~dp0"
powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0run_parabdi.ps1" %*
set "EXITCODE=%ERRORLEVEL%"
echo.
echo [Run-Parabdi] exited with code %EXITCODE%
pause
endlocal
