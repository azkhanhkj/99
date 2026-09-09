@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Recaf 4.x Installer

set "TARGET_USER=%~1"
if "%TARGET_USER%"=="" set "TARGET_USER=ServerPremium"

set "JDK=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-101.0\x64"
set "JAVA=%JDK%\bin\java.exe"
set "JAVAW=%JDK%\bin\javaw.exe"
set "SOURCE_ICON=%~dp0..\assets\recaf.ico"
if not exist "%SOURCE_ICON%" set "SOURCE_ICON=%~dp0..\assets\76870919.ico"

:: Choose install directory based on privilege
net session >nul 2>&1
if errorlevel 1 (
    set "INSTALL_DIR=C:\Users\%TARGET_USER%\AppData\Local\Programs\Recaf"
) else (
    set "INSTALL_DIR=%ProgramFiles%\Recaf"
)

set "JAR=%INSTALL_DIR%\Recaf.jar"
set "ICON=%INSTALL_DIR%\Recaf.ico"
set "URL=https://github.com/Col-E/Recaf/releases/download/4.0.0-alpha/recaf-4x-alpha-win-86-x64.jar"

if not exist "%JAVA%" (
    echo [ERROR] Java executable not found: %JAVA%
    exit /b 1
)

if not exist "%JAVAW%" (
    echo [ERROR] javaw.exe not found: %JAVAW%
    exit /b 1
)

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" >nul 2>&1

:: Check if already downloaded and valid (>10MB)
set "NEED_DOWNLOAD=1"
if exist "%JAR%" (
    for %%F in ("%JAR%") do (
        if %%~zF gtr 10000000 set "NEED_DOWNLOAD=0"
    )
)

if "%NEED_DOWNLOAD%"=="1" (
    echo [*] Downloading Recaf 4.x...
    curl.exe -L --fail --show-error ^
        --retry 3 ^
        --retry-delay 1 ^
        --connect-timeout 10 ^
        -o "%JAR%" "%URL%"

    if errorlevel 1 (
        echo [ERROR] Failed to download Recaf.
        exit /b 1
    )
) else (
    echo [*] Recaf 4.x already present.
)

if exist "%SOURCE_ICON%" (
    copy /Y "%SOURCE_ICON%" "%ICON%" >nul 2>&1
)

echo [*] Creating shortcuts for Recaf 4.x...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$desktops = @('C:\Users\%TARGET_USER%\Desktop', [Environment]::GetFolderPath('CommonDesktopDirectory')) | Where-Object { Test-Path $_ };" ^
    "foreach ($d in $desktops) {" ^
    "    $s = $ws.CreateShortcut(\"$d\Recaf.lnk\");" ^
    "    $s.TargetPath = '%JAVAW%';" ^
    "    $s.Arguments = '-jar \"\"%JAR%\"\"';" ^
    "    $s.WorkingDirectory = '%INSTALL_DIR%';" ^
    "    if (Test-Path '%ICON%') { $s.IconLocation = '%ICON%,0' };" ^
    "    $s.Description = 'Recaf 4.x Bytecode Editor';" ^
    "    try { $s.Save() } catch {}" ^
    "}"

echo [*] Recaf 4.x installed successfully.
exit /b 0