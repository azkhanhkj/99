@echo off
setlocal EnableExtensions

title Install Recaf

echo ==========================================
echo        Installing Recaf
echo ==========================================
echo.

set "INSTALL_DIR=%ProgramFiles%\Recaf"
set "DOWNLOAD_DIR=%TEMP%\RecafInstall"
set "JAR=%DOWNLOAD_DIR%\recaf.jar"

if not exist "%DOWNLOAD_DIR%" mkdir "%DOWNLOAD_DIR%"

:: ==========================================
:: Check Java
:: ==========================================

where java >nul 2>&1

if errorlevel 1 (
    echo [INFO] Java not found.
    echo [INFO] Installing Java 21...

    powershell -NoProfile -ExecutionPolicy Bypass -Command ^
        "winget install --id EclipseAdoptium.Temurin.21.JDK --exact --silent --accept-package-agreements --accept-source-agreements"

    if errorlevel 1 (
        echo [ERROR] Failed to install Java.
        exit /b 1
    )
)

:: Refresh PATH
set "PATH=%ProgramFiles%\Eclipse Adoptium\jdk-21*\bin;%PATH%"

where java >nul 2>&1

if errorlevel 1 (
    echo [ERROR] Java is still unavailable.
    echo Please restart the terminal and run this script again.
    exit /b 1
)

echo [OK] Java detected.
java -version

echo.
echo ==========================================
echo Downloading Recaf
echo ==========================================
echo.

:: ==========================================
:: Get latest Recaf release from GitHub
:: ==========================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$r = Invoke-RestMethod 'https://api.github.com/repos/Col-E/Recaf/releases/latest';" ^
    "$asset = $r.assets | Where-Object { $_.name -match '\.jar$' -and $_.name -notmatch 'sources|javadoc' } | Select-Object -First 1;" ^
    "if (-not $asset) { throw 'Recaf JAR not found.' };" ^
    "Write-Host ('Downloading ' + $asset.name);" ^
    "Invoke-WebRequest $asset.browser_download_url -OutFile '%JAR%'"

if errorlevel 1 (
    echo [ERROR] Failed to download Recaf.
    exit /b 1
)

if not exist "%JAR%" (
    echo [ERROR] Recaf JAR was not downloaded.
    exit /b 1
)

echo [OK] Recaf downloaded.

:: ==========================================
:: Install
:: ==========================================

if not exist "%INSTALL_DIR%" mkdir "%INSTALL_DIR%"

copy /Y "%JAR%" "%INSTALL_DIR%\Recaf.jar" >nul

if errorlevel 1 (
    echo [ERROR] Failed to install Recaf.
    exit /b 1
)

:: ==========================================
:: Create launcher
:: ==========================================

(
echo @echo off
echo java -jar "%INSTALL_DIR%\Recaf.jar" %%*
) > "%INSTALL_DIR%\Recaf.bat"

:: ==========================================
:: Desktop shortcut
:: ==========================================

powershell -NoProfile -ExecutionPolicy Bypass -Command ^
    "$ws = New-Object -ComObject WScript.Shell;" ^
    "$s = $ws.CreateShortcut([Environment]::GetFolderPath('Desktop') + '\Recaf.lnk');" ^
    "$s.TargetPath = 'java.exe';" ^
    "$s.Arguments = '-jar ""%INSTALL_DIR%\Recaf.jar""';" ^
    "$s.WorkingDirectory = '%INSTALL_DIR%';" ^
    "$s.IconLocation = 'java.exe,0';" ^
    "$s.Save()"

echo.
echo ==========================================
echo Recaf installed successfully.
echo ==========================================
echo.
echo Location:
echo %INSTALL_DIR%\Recaf.jar
echo.
echo Starting Recaf...
echo.

start "" java -jar "%INSTALL_DIR%\Recaf.jar"

endlocal
exit /b 0