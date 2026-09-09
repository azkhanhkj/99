@echo off
setlocal

title Recaf 4.x Installer

set "INSTALL_DIR=%ProgramFiles%\Recaf"
set "JDK=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-101.0\x64"
set "JAVA=%JDK%\bin\java.exe"
set "JAVAW=%JDK%\bin\javaw.exe"
set "JAR=%INSTALL_DIR%\Recaf.jar"
set "SOURCE_ICON=%~dp0..\assets\recaf.ico"
if not exist "%SOURCE_ICON%" set "SOURCE_ICON=%~dp0..\assets\76870919.ico"
set "ICON=%INSTALL_DIR%\Recaf.ico"
set "URL=https://github.com/Col-E/Recaf/releases/download/4.0.0-alpha/recaf-4x-alpha-win-86-x64.jar"

net session >nul 2>&1 || (
    echo [ERROR] Run this script as Administrator.
    exit /b 1
)

if not exist "%JAVA%" (
    echo [ERROR] Java executable not found: %JAVA%
    exit /b 1
)

if not exist "%JAVAW%" (
    echo [ERROR] javaw.exe not found: %JAVAW%
    exit /b 1
)

set "JAVA_HOME=%JDK%"
set "PATH=%JDK%\bin;%PATH%"

"%JAVA%" -version >nul 2>&1
if errorlevel 1 (
    echo [ERROR] Java 25 verification failed.
    exit /b 1
)

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%" >nul 2>&1
if not exist "%INSTALL_DIR%" (
    echo [ERROR] Cannot create install directory: %INSTALL_DIR%
    exit /b 1
)

echo Downloading Recaf 4.x...
curl.exe -L --fail --silent --show-error ^
    --retry 3 ^
    --retry-delay 1 ^
    --connect-timeout 10 ^
    -o "%JAR%" "%URL%"

if errorlevel 1 (
    echo [ERROR] Failed to download Recaf.
    exit /b 1
)

if not exist "%JAR%" (
    echo [ERROR] Recaf.jar not found after download.
    exit /b 1
)

if exist "%SOURCE_ICON%" (
    copy /Y "%SOURCE_ICON%" "%ICON%" >nul 2>&1
)

powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$java = '%JAVAW%';" ^
    "$jar = '%JAR%';" ^
    "$icon = '%ICON%';" ^
    "$work = '%INSTALL_DIR%';" ^
    "$startMenu = Join-Path ([Environment]::GetFolderPath('CommonPrograms')) 'Recaf.lnk';" ^
    "$desktop = Join-Path ([Environment]::GetFolderPath('CommonDesktopDirectory')) 'Recaf.lnk';" ^
    "$targets = @($startMenu, $desktop);" ^
    "foreach ($path in $targets) {" ^
        "try {" ^
            "$s = $ws.CreateShortcut($path);" ^
            "$s.TargetPath = $java;" ^
            "$s.Arguments = '-jar ""' + $jar + '""';" ^
            "$s.WorkingDirectory = $work;" ^
            "if (Test-Path $icon) { $s.IconLocation = $icon + ',0'; }" ^
            "$s.Description = 'Recaf 4.x';" ^
            "$s.Save();" ^
        "} catch {}" ^
    "}" >nul 2>&1

echo Recaf 4.x installed successfully.

endlocal
exit /b 0