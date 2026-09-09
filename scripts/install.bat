@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Application & Environment Setup

set "TARGET_USER=ServerPremium"

echo ============================================================
echo 1. TOI UU HE THONG VA WINDOWS DEFENDER
echo ============================================================
if exist "%~dp0setup-performance.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-performance.ps1"
)

echo ============================================================
echo 2. THIET LAP JAVA VA MOI TRUONG TOOLCACHE
echo ============================================================
set "DEFAULT_JAVA=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64"
set "JAVA_HOME=%DEFAULT_JAVA%"
set "PATH=%DEFAULT_JAVA%\bin;%PATH%"
set "GHIDRA_JAVA_HOME=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\21.0.12-101.0\x64"

echo ============================================================
echo 3. CAI DAT BUN VA AI CODING AGENTS
echo ============================================================
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"
call refreshenv

set "PATH=%USERPROFILE%\.bun\bin;C:\Users\%TARGET_USER%\.bun\bin;%PATH%"

call bun add -g --ignore-scripts @earendil-works/pi-coding-agent
call bun add -g opencode-ai

echo ============================================================
echo 4. CAI DAT CHOCOLATEY PACKAGES (BO QUA JDK DA CO SAN)
echo ============================================================
choco feature enable -n allowGlobalConfirmation >nul 2>&1
choco install github-desktop intellijidea-community antigravity-ide vscode ghidra --yes --no-progress

echo ============================================================
echo 5. CAI DAT RECAF 4.X
echo ============================================================
if exist "%~dp0recaf.bat" (
    call "%~dp0recaf.bat"
)

echo ============================================================
echo 6. CAU HINH POWERSHELL PROFILE (SET-JAVA)
echo ============================================================
if exist "%~dp0setup-profile.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-profile.ps1" -TargetUser "%TARGET_USER%"
)

echo ============================================================
echo 7. TAO DESKTOP SHORTCUTS
echo ============================================================
if exist "%~dp0setup-shortcuts.ps1" (
    powershell.exe -NoProfile -ExecutionPolicy Bypass -File "%~dp0setup-shortcuts.ps1" -TargetUser "%TARGET_USER%"
)

echo ============================================================
echo HOAN TAT TOAN BO SETUP!
echo ============================================================