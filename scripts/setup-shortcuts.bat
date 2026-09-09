@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Setup Shortcuts

set "TARGET_USER=%~1"
if "%TARGET_USER%"=="" set "TARGET_USER=ServerPremium"

echo [*] Setting up Ghidra environment and shortcuts for %TARGET_USER%...

:: Set GHIDRA_JAVA_HOME to JDK 21
set "JDK21=%JAVA_HOME_21_X64%"
if exist "%JDK21%" (
    setx GHIDRA_JAVA_HOME "%JDK21%" >nul 2>&1
    setx GHIDRA_JAVA_HOME "%JDK21%" /M >nul 2>&1
)

:: Locate Ghidra installation directory
set "GHIDRA_ROOT="
for /d %%d in ("C:\ProgramData\chocolatey\lib\ghidra\tools\ghidra_*") do (
    set "GHIDRA_ROOT=%%d"
)

if not defined GHIDRA_ROOT (
    echo [!] Ghidra installation directory not found.
    exit /b 0
)

set "GHIDRA_BAT=%GHIDRA_ROOT%\ghidraRun.bat"
set "GHIDRA_ICON=%GHIDRA_ROOT%\support\ghidra.ico"

if not exist "%GHIDRA_BAT%" (
    echo [!] ghidraRun.bat not found at %GHIDRA_BAT%.
    exit /b 0
)

:: Create shortcuts on User Desktop and Public Desktop
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$desktops = @('C:\Users\%TARGET_USER%\Desktop', [Environment]::GetFolderPath('CommonDesktopDirectory')) | Where-Object { Test-Path $_ };" ^
    "foreach ($d in $desktops) {" ^
    "    $s = $ws.CreateShortcut(\"$d\Ghidra.lnk\");" ^
    "    $s.TargetPath = '%GHIDRA_BAT%';" ^
    "    $s.WorkingDirectory = '%GHIDRA_ROOT%';" ^
    "    if (Test-Path '%GHIDRA_ICON%') { $s.IconLocation = '%GHIDRA_ICON%,0' };" ^
    "    $s.Description = 'Ghidra Software Reverse Engineering Framework';" ^
    "    try { $s.Save() } catch {}" ^
    "}"

echo [*] Created Ghidra shortcut successfully.
exit /b 0
