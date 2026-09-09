@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Setup

set "TARGET_USER=ServerPremium"

if /I not "%USERNAME%"=="%TARGET_USER%" (
    echo [WARNING] This script must run as %TARGET_USER%.
    exit /b 0
)

echo =======================================================
echo          PREMIUM SERVER - APPLICATION SETUP
echo =======================================================

echo [1/8] Optimizing system and Defender settings...
if exist "%~dp0setup-performance.bat" (
    call "%~dp0setup-performance.bat"
)

echo [2/8] Configuring default Java environment...
set "DEFAULT_JAVA=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64"
set "JAVA_HOME=%DEFAULT_JAVA%"
set "PATH=%DEFAULT_JAVA%\bin;%PATH%"
set "GHIDRA_JAVA_HOME=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\21.0.12-101.0\x64"
setx JAVA_HOME "%DEFAULT_JAVA%" >nul 2>&1
setx GHIDRA_JAVA_HOME "%GHIDRA_JAVA_HOME%" >nul 2>&1

echo [3/8] Installing Bun and AI agents...
where bun >nul 2>&1
if errorlevel 1 (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
)
set "PATH=%USERPROFILE%\.bun\bin;%PATH%"

where pi >nul 2>&1
if errorlevel 1 (
    call bun add -g --ignore-scripts @earendil-works/pi-coding-agent
)
where opencode >nul 2>&1
if errorlevel 1 (
    call bun add -g opencode-ai
)

echo [4/8] Installing applications via Chocolatey...
choco feature enable -n allowGlobalConfirmation >nul 2>&1
choco install intellijidea-community --version 2024.3.5 --allow-downgrade --yes --no-progress
choco install github-desktop antigravity-ide antigravity-cli vscode ghidra --yes --no-progress

where agy >nul 2>&1 && call agy plugin install https://github.com/obra/superpowers
where pi >nul 2>&1 && call pi install git:github.com/obra/superpowers

echo [5/8] Installing Recaf 4.x...
if exist "%~dp0recaf.bat" (
    call "%~dp0recaf.bat" "%TARGET_USER%"
)

echo [6/8] Configuring terminal profile and set-java command...
if exist "%~dp0setup-profile.bat" (
    call "%~dp0setup-profile.bat" "%TARGET_USER%"
)

echo [7/8] Generating Ghidra shortcut...
if exist "%~dp0setup-shortcuts.bat" (
    call "%~dp0setup-shortcuts.bat" "%TARGET_USER%"
)

echo [8/8] Uninstalling bloatware and stopping unused services...
if exist "%~dp0uninstall.bat" (
    call "%~dp0uninstall.bat"
)

echo =======================================================
echo Setup completed successfully!
echo =======================================================
exit /b 0