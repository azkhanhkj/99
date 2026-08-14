@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Application Installer

set "TARGET_USER=ServerPremium"

if /I not "%USERNAME%"=="%TARGET_USER%" (
    exit /b 0
)

choco feature enable -n allowGlobalConfirmation
choco install intellijidea-community --version 2024.1.5 --yes
choco install github-desktop temurin17 temurin8 ghidra bun --yes
bun i -g opencode-ai

exit /b 0