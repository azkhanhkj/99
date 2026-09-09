@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Paseo Installer

set "TARGET_USER=%~1"
if "%TARGET_USER%"=="" set "TARGET_USER=ServerPremium"

set "INSTALL_DIR=C:\Users\%TARGET_USER%\AppData\Local\Programs\Paseo"
set "EXE=%INSTALL_DIR%\Paseo.exe"
set "VERSION=0.7.2"
set "SETUP_URL=https://github.com/getpaseo/paseo/releases/download/v%VERSION%/Paseo-Setup-%VERSION%-x64.exe"
set "TEMP_SETUP=%TEMP%\Paseo-Setup.exe"

echo [*] Setting up Paseo for %TARGET_USER%...

:: 1. Install Paseo Desktop App
if exist "%EXE%" (
    echo [*] Paseo Desktop is already installed at %EXE%.
) else (
    echo [*] Downloading Paseo Desktop v%VERSION%...
    curl.exe -L --fail --show-error ^
        --retry 3 ^
        --retry-delay 1 ^
        --connect-timeout 10 ^
        -o "%TEMP_SETUP%" "%SETUP_URL%"

    if errorlevel 1 (
        echo [ERROR] Failed to download Paseo Desktop Setup.
    ) else (
        echo [*] Installing Paseo Desktop silently...
        start /wait "" "%TEMP_SETUP%" /S
        if exist "%TEMP_SETUP%" del /f /q "%TEMP_SETUP%" >nul 2>&1
        echo [*] Paseo Desktop installation finished.
    )
)

:: 2. Install Paseo CLI globally
echo [*] Checking Paseo CLI...
where paseo >nul 2>&1
if errorlevel 1 (
    echo [*] Installing Paseo CLI globally [@getpaseo/cli]...
    call npm install -g @getpaseo/cli
) else (
    echo [*] Paseo CLI is already installed.
)

exit /b 0
