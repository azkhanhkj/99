@echo off
setlocal

set /a SECONDS=21500
set /a ELAPSED=0

echo ==========================================
echo Premium Server - Keep Alive
echo ==========================================

:loop

if %ELAPSED% GEQ %SECONDS% goto end

echo Running... %ELAPSED% / %SECONDS% seconds

REM 10 second sleep without timeout/stdin
ping 127.0.0.1 -n 11 >nul

set /a ELAPSED+=10

goto loop

:end

echo.
echo Keep alive finished.

exit /b 0