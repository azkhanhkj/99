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

echo [1/7] Optimizing system and Defender settings...
if exist "%~dp0setup-performance.bat" (
    call "%~dp0setup-performance.bat"
)

echo [2/7] Configuring default Java environment...
set "DEFAULT_JAVA=%JAVA_HOME_17_X64%"
set "JAVA_HOME=%DEFAULT_JAVA%"
set "PATH=%DEFAULT_JAVA%\bin;%PATH%"

set "GHIDRA_JAVA_HOME=%JAVA_HOME_21_X64%"
setx JAVA_HOME "%DEFAULT_JAVA%" >nul 2>&1
setx GHIDRA_JAVA_HOME "%GHIDRA_JAVA_HOME%" >nul 2>&1

echo [3/7] Installing Bun and AI agents...
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

echo [4/7] Installing applications via Chocolatey...
choco feature enable -n allowGlobalConfirmation >nul 2>&1
choco install intellijidea-community --version 2024.3.5 --allow-downgrade --yes --no-progress
choco install github-desktop antigravity-ide antigravity-cli vscode ghidra unikey --yes --no-progress

where agy >nul 2>&1 && call agy plugin install https://github.com/obra/superpowers
where pi >nul 2>&1 && call pi install git:github.com/obra/superpowers

echo [5/7] Installing Paseo Desktop and CLI...
if exist "%~dp0paseo.bat" (
    call "%~dp0paseo.bat" "%TARGET_USER%"
)

echo [6/7] Installing Recaf 4.x...
if exist "%~dp0recaf.bat" (
    call "%~dp0recaf.bat" "%TARGET_USER%"
)

echo [7/7] Uninstalling bloatware and stopping unused services...
if exist "%~dp0uninstall.bat" (
    call "%~dp0uninstall.bat"
)

echo =======================================================
echo Setup completed successfully!
echo =======================================================
exit /b 0