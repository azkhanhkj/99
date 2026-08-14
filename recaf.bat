@echo off
setlocal

title Recaf 4.x Installer

:: ============================================================
:: Config
:: ============================================================

set "INSTALL_DIR=%ProgramFiles%\Recaf"
set "JDK=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-7.0\x64"
set "JAVA=%JDK%\bin\java.exe"
set "JAVAW=%JDK%\bin\javaw.exe"
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

if not exist "%JAVA%" exit /b 1
if not exist "%JAVAW%" exit /b 1

set "JAVA_HOME=%JDK%"
set "PATH=%JDK%\bin;%PATH%"

"%JAVA%" -version >nul 2>&1
if errorlevel 1 exit /b 1

:: ============================================================
:: Install directory
:: ============================================================

if not exist "%INSTALL_DIR%" (
    mkdir "%INSTALL_DIR%" >nul 2>&1
)

:: ============================================================
:: Download
:: ============================================================

curl.exe -L --fail --silent --show-error ^
    --retry 3 ^
    --retry-delay 1 ^
    --connect-timeout 10 ^
    -o "%JAR%" "%URL%" >nul 2>&1

if errorlevel 1 exit /b 1
if not exist "%JAR%" exit /b 1

:: ============================================================
:: Icon
:: ============================================================

if exist "%ICON%" (
    copy /Y "%ICON%" "%INSTALL_DIR%\Recaf.ico" >nul 2>&1
)

:: ============================================================
:: Icon
:: ============================================================

set "ICON=%INSTALL_DIR%\Recaf.ico"
set "ICON_URL=https://avatars.githubusercontent.com/u/76870919?s=280&v=4"

powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ^
    "$url='%ICON_URL%';" ^
    "$out='%ICON%';" ^
    "$tmp='%TEMP%\recaf-avatar.png';" ^
    "try {" ^
        "[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12;" ^
        "Invoke-WebRequest -Uri $url -OutFile $tmp -UseBasicParsing;" ^
        "Add-Type -AssemblyName System.Drawing;" ^
        "$img=[System.Drawing.Image]::FromFile($tmp);" ^
        "$bmp=New-Object System.Drawing.Bitmap 256,256;" ^
        "$g=[System.Drawing.Graphics]::FromImage($bmp);" ^
        "$g.DrawImage($img,0,0,256,256);" ^
        "$g.Dispose();" ^
        "$img.Dispose();" ^
        "$fs=[System.IO.File]::Open($out,[System.IO.FileMode]::Create);" ^
        "$writer=New-Object System.IO.BinaryWriter($fs);" ^
        "$writer.Write([byte]0);$writer.Write([byte]0);" ^
        "$writer.Write([byte]1);$writer.Write([byte]0);" ^
        "$writer.Write([byte]1);$writer.Write([byte]0);" ^
        "$writer.Write([byte]0);" ^
        "$writer.Write([byte]0);" ^
        "$writer.Write([byte]0);" ^
        "$writer.Write([byte]0);" ^
        "$writer.Write([byte]0);" ^
        "$writer.Write([byte]0);" ^
        "$writer.Write([byte]0);" ^
        "$writer.Write([byte]0);" ^
        "$writer.Write([int]40);" ^
        "$writer.Write([int]54);" ^
        "$bmp.Save($fs,[System.Drawing.Imaging.ImageFormat]::Png);" ^
        "$writer.Close();$fs.Close();" ^
        "$bmp.Dispose();" ^
        "Remove-Item $tmp -Force -ErrorAction SilentlyContinue" ^
    "} catch {}" >nul 2>&1

:: ============================================================
:: Shortcuts
:: ============================================================

powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -Command ^
    "$ws=New-Object -ComObject WScript.Shell;" ^
    "$icon='%ICON%';" ^
    "$java='%JAVAW%';" ^
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
    "}" >nul 2>&1

:: ============================================================
:: Launch Recaf WITHOUT console
:: ============================================================

start "" "%JAVAW%" -jar "%JAR%"

endlocal
exit /b 0