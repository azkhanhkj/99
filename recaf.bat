```bat
@echo off
setlocal

title Recaf 4.x Installer

:: ============================================================
:: Config
:: ============================================================

set "INSTALL_DIR=%ProgramFiles%\Recaf"
set "JDK=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-7.0\x64"
set "JAVA=%JDK%\bin\java.exe"
set "JAR=%INSTALL_DIR%\Recaf.jar"
set "ICON=%~dp0Recaf.ico"
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

echo [1/4] Checking Java 25...

if not exist "%JAVA%" (
    echo [ERROR] Java 25 not found:
    echo %JDK%
    exit /b 1
)

set "JAVA_HOME=%JDK%"
set "PATH=%JDK%\bin;%PATH%"

"%JAVA%" -version || (
    echo [ERROR] Java 25 cannot be executed.
    exit /b 1
)

echo [OK] Java 25
echo.

:: ============================================================
:: Install directory
:: ============================================================

echo [2/4] Preparing Recaf...

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

:: ============================================================
:: Download
:: ============================================================

echo [3/4] Downloading Recaf...

curl.exe -L --fail --retry 3 --retry-delay 1 --connect-timeout 10 ^
    -o "%JAR%" "%URL%"

if errorlevel 1 (
    echo [ERROR] Download failed.
    exit /b 1
)

if not exist "%JAR%" (
    echo [ERROR] Recaf.jar not found.
    exit /b 1
)

echo [OK] Recaf installed:
echo      %JAR%
echo.

:: ============================================================
:: Icon
:: ============================================================

if exist "%ICON%" copy /Y "%ICON%" "%INSTALL_DIR%\Recaf.ico" >nul

:: ============================================================
:: Shortcuts
:: ============================================================

echo [4/4] Creating shortcuts...

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ws=New-Object -ComObject WScript.Shell;" ^
    "$icon='%INSTALL_DIR%\Recaf.ico';" ^
    "$java='%JAVA%';" ^
    "$jar='%JAR%';" ^
    "$work='%INSTALL_DIR%';" ^
    "$targets=@(" ^
        "'%ProgramData%\Microsoft\Windows\Start Menu\Programs\Recaf.lnk'," ^
        "'[Environment]::GetFolderPath(''CommonDesktopDirectory'')\Recaf.lnk'" ^
    ");" ^
    "$targets[1]=[Environment]::GetFolderPath('CommonDesktopDirectory')+'\Recaf.lnk';" ^
    "foreach($p in $targets){" ^
        "$s=$ws.CreateShortcut($p);" ^
        "$s.TargetPath=$java;" ^
        "$s.Arguments='-jar ""'+$jar+'""';" ^
        "$s.WorkingDirectory=$work;" ^
        "if(Test-Path $icon){$s.IconLocation=$icon+',0'};" ^
        "$s.Description='Recaf 4.x';" ^
        "$s.Save()" ^
    "}"

echo [OK] Shortcuts created.
echo.

:: ============================================================
:: Launch
:: ============================================================

echo Starting Recaf...
start "" "%JAVA%" -jar "%JAR%"

echo.
echo ============================================================
echo             Recaf 4.x Installation Complete
echo ============================================================
echo.
echo Location: %JAR%
echo Java:     %JAVA%
echo.

endlocal
exit /b 0
```
