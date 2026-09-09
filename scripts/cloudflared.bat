@echo off
setlocal

set "INSTALL_DIR=C:\Cloudflared\bin"
set "EXE=%INSTALL_DIR%\cloudflared.exe"
set "URL=https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe"

echo ==========================================
echo Installing Cloudflared
echo ==========================================

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

echo Downloading latest Cloudflared...

curl.exe -L ^
    --fail ^
    --retry 3 ^
    --retry-delay 1 ^
    --connect-timeout 10 ^
    -o "%EXE%" ^
    "%URL%"

if errorlevel 1 (
    echo Failed to download Cloudflared.
    exit /b 1
)

if not exist "%EXE%" (
    echo Cloudflared executable not found.
    exit /b 1
)

echo.
echo Cloudflared version:
"%EXE%" --version

echo.
echo ==========================================
echo Installing Cloudflare Tunnel service
echo ==========================================

"%EXE%" service install "%CF_TOKEN%"

if errorlevel 1 (
    echo Failed to install Cloudflare Tunnel service.
    exit /b 1
)

echo.
echo Cloudflare Tunnel installed successfully.

exit /b 0