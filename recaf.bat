@echo off
setlocal

title Recaf 4.x Installer

:: ============================================================
:: Config
:: ============================================================

set "INSTALL_DIR=%ProgramFiles%\Recaf"
set "JDK=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-101.0\x64"
set "JAVA=%JDK%\bin\java.exe"
set "JAVAW=%JDK%\bin\javaw.exe"
set "JAR=%INSTALL_DIR%\Recaf.jar"

:: Icon nằm cùng thư mục với recaf.bat
set "SOURCE_ICON=%~dp076870919.ico"
set "ICON=%INSTALL_DIR%\Recaf.ico"

set "URL=https://github.com/Col-E/Recaf/releases/download/4.0.0-alpha/recaf-4x-alpha-win-86-x64.jar"

:: ============================================================
:: Admin
:: ============================================================

net session >nul 2>&1 || (
    echo [ERROR] Run this script as Administrator.
    pause
    exit /b 1
)

:: ============================================================
:: Java 25
:: ============================================================

if not exist "%JAVA%" (
    echo [ERROR] Java executable not found:
    echo %JAVA%
    pause
    exit /b 1
)

if not exist "%JAVAW%" (
    echo [ERROR] javaw.exe not found:
    echo %JAVAW%
    pause
    exit /b 1
)

set "JAVA_HOME=%JDK%"
set "PATH=%JDK%\bin;%PATH%"

"%JAVA%" -version >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Java 25 is not working.
    pause
    exit /b 1
)

:: ============================================================
:: Install directory
:: ============================================================

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >nul 2>&1
)

if not exist "%INSTALL_DIR%" (
    echo [ERROR] Cannot create:
    echo %INSTALL_DIR%
    pause
    exit /b 1
)

:: ============================================================
:: Download Recaf
:: ============================================================

echo [INFO] Downloading Recaf...

curl.exe -L --fail --silent --show-error ^
    --retry 3 ^
    --retry-delay 1 ^
    --connect-timeout 10 ^
    -o "%JAR%" "%URL%"

if errorlevel 1 (
    echo [ERROR] Failed to download Recaf.
    pause
    exit /b 1
)

if not exist "%JAR%" (
    echo [ERROR] Recaf.jar was not downloaded.
    pause
    exit /b 1
)

:: ============================================================
:: Install Icon
:: ============================================================

if not exist "%SOURCE_ICON%" (
    echo [ERROR] Icon not found:
    echo %SOURCE_ICON%
    pause
    exit /b 1
)

echo [INFO] Installing icon...

copy /Y "%SOURCE_ICON%" "%ICON%" >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Failed to copy icon.
    pause
    exit /b 1
)

if not exist "%ICON%" (
    echo [ERROR] Installed icon was not found:
    echo %ICON%
    pause
    exit /b 1
)

:: ============================================================
:: Create Shortcuts
:: ============================================================

echo [INFO] Creating shortcuts...

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
        "$s = $ws.CreateShortcut($path);" ^
        "$s.TargetPath = $java;" ^
        "$s.Arguments = '-jar ""' + $jar + '""';" ^
        "$s.WorkingDirectory = $work;" ^
        "$s.IconLocation = $icon + ',0';" ^
        "$s.Description = 'Recaf 4.x';" ^
        "$s.Save();" ^
    "}" >nul 2>&1

:: ============================================================
:: Done
:: ============================================================

echo.
echo ============================================================
echo Recaf 4.x installed successfully.
echo ============================================================
echo.
echo Install directory:
echo %INSTALL_DIR%
echo.
echo Shortcut icon:
echo %ICON%
echo.

:: ============================================================
:: Launch Recaf WITHOUT console
:: ============================================================

start "" "%JAVAW%" -jar "%JAR%"

endlocal
exit /b 0