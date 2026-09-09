@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Setup

set "TARGET_USER=ServerPremium"

if /I not "%USERNAME%"=="%TARGET_USER%" (
    echo [WARNING] This script must run as %TARGET_USER%.
    exit /b 0
)

echo [1/8] Optimizing system and Defender settings...
if exist "%~dp0setup-performance.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-performance.ps1"
)

echo [2/8] Configuring default Java environment...
set "DEFAULT_JAVA=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64"
set "JAVA_HOME=%DEFAULT_JAVA%"
set "PATH=%DEFAULT_JAVA%\bin;%PATH%"
set "GHIDRA_JAVA_HOME=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\21.0.12-101.0\x64"

echo [3/8] Installing Bun and AI agents...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
call refreshenv

set "PATH=%USERPROFILE%\.bun\bin;%PATH%"

call bun add -g --ignore-scripts @earendil-works/pi-coding-agent
call bun add -g opencode-ai

echo [4/8] Installing applications via Chocolatey...
choco feature enable -n allowGlobalConfirmation >nul 2>&1
choco install intellijidea-community --version 2024.3 --allow-downgrade --yes --no-progress
choco install github-desktop antigravity-ide antigravity-cli vscode ghidra --yes --no-progress

echo [5/8] Installing Recaf 4.x...
if exist "%~dp0recaf.bat" (
    call "%~dp0recaf.bat"
)

echo [6/8] Configuring PowerShell profile...
if exist "%~dp0setup-profile.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-profile.ps1" -TargetUser "%TARGET_USER%"
)

echo [7/8] Generating Ghidra shortcut...
if exist "%~dp0setup-shortcuts.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-shortcuts.ps1" -TargetUser "%TARGET_USER%"
)

echo [8/8] Uninstalling bloatware and stopping unused services...
if exist "%~dp0uninstall.bat" (
    call "%~dp0uninstall.bat"
)

echo Setup completed successfully.