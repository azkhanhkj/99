@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Application Installer

set "TARGET_USER=ServerPremium"

if /I not "%USERNAME%"=="%TARGET_USER%" (
    exit /b 0
)

npm i -g opencode-ai
choco feature enable -n allowGlobalConfirmation >nul 2>&1
choco install intellijidea-community --version 2024.1.5 --yes
choco install github-desktop temurin17 temurin8 ghidra --yes

exit /b 0