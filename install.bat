@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Application Installer

set "TARGET_USER=ServerPremium"

if /I not "%USERNAME%"=="%TARGET_USER%" (
    exit /b 0
)

powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
call refreshenv
choco install github-desktop temurin17 temurin8 intellijidea-community antigravity-ide vscode ghidra --yes
bun add -g --ignore-scripts @earendil-works/pi-coding-agent
bun add -g opencode-ai