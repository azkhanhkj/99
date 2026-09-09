@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Setup

set "TARGET_USER=ServerPremium"

echo [1/7] Optimizing system and Defender settings...
if exist "%~dp0setup-performance.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-performance.ps1"
)

echo [2/7] Configuring default Java environment...
set "DEFAULT_JAVA=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64"
set "JAVA_HOME=%DEFAULT_JAVA%"
set "PATH=%DEFAULT_JAVA%\bin;%PATH%"
set "GHIDRA_JAVA_HOME=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\21.0.12-101.0\x64"

echo [3/7] Installing Bun and AI agents...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
call refreshenv

set "PATH=%USERPROFILE%\.bun\bin;C:\Users\%TARGET_USER%\.bun\bin;%PATH%"

call bun add -g --ignore-scripts @earendil-works/pi-coding-agent
call bun add -g opencode-ai

echo [4/7] Installing applications via Chocolatey...
choco feature enable -n allowGlobalConfirmation >nul 2>&1
choco install intellijidea-community --version 2024.3 --allow-downgrade --yes --no-progress
choco install github-desktop antigravity-ide antigravity-cli vscode ghidra --yes --no-progress

echo [5/7] Installing Recaf 4.x...
if exist "%~dp0recaf.bat" (
    call "%~dp0recaf.bat"
)

echo [6/7] Configuring PowerShell profile...
if exist "%~dp0setup-profile.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-profile.ps1" -TargetUser "%TARGET_USER%"
)

echo [7/7] Generating desktop shortcuts...
if exist "%~dp0setup-shortcuts.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-shortcuts.ps1" -TargetUser "%TARGET_USER%"
)

echo Setup completed successfully.