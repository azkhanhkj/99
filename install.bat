@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Application Installer

set "TARGET_USER=ServerPremium"

if /I not "%USERNAME%"=="%TARGET_USER%" (
    exit /b 0
)

choco feature enable -n allowGlobalConfirmation
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
call refreshenv
choco install intellijidea-community github-desktop antigravity-ide temurin17 temurin8 vscode ghidra --yes
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://omp.sh/install.ps1 | iex"
bun add -g opencode-ai