@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Application Installer

set "TARGET_USER=ServerPremium"

if /I not "%USERNAME%"=="%TARGET_USER%" (
    exit /b 0
)

choco feature enable -n allowGlobalConfirmation

choco install intellijidea-community --version 2024.1.5 --yes
choco install opencode github-desktop temurin17 temurin8 ghidra --yes

:: Install Bun using the official installer
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"

exit /b 0