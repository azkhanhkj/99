@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Application Installer

REM ============================================================
REM Configuration
REM ============================================================

set "TARGET_USER=ServerPremium"
set "LOG_DIR=%ProgramData%\PremiumServer"
set "LOG_FILE=%LOG_DIR%\login-install.log"

REM ============================================================
REM Only run for the intended RDP user
REM ============================================================

if /I not "%USERNAME%"=="%TARGET_USER%" (
    exit /b 0
)

REM ============================================================
REM Create log directory
REM ============================================================

if not exist "%LOG_DIR%" mkdir "%LOG_DIR%" >nul

echo.
echo ============================================================
echo [%DATE% %TIME%] Login detected: %USERNAME%
echo ============================================================

echo.
echo ============================================================
echo              PREMIUM SERVER
echo ============================================================
echo.
echo User: %USERNAME%
echo.
echo Installing applications using Chocolatey...
echo.
echo ============================================================
echo.

REM ============================================================
REM Locate Chocolatey
REM ============================================================

echo Checking Chocolatey...

set "CHOCO_EXE="

if exist "%ProgramData%\chocolatey\bin\choco.exe" (
    set "CHOCO_EXE=%ProgramData%\chocolatey\bin\choco.exe"
)

if not defined CHOCO_EXE (
    where choco.exe >nul

    if not errorlevel 1 (
        set "CHOCO_EXE=choco.exe"
    )
)

if not defined CHOCO_EXE (
    echo.
    echo ERROR: Chocolatey is not available.
    echo [%DATE% %TIME%] ERROR: Chocolatey not found
    echo.
    echo Please install Chocolatey first.
    echo.
    pause
    exit /b 1
)

echo Chocolatey found:
echo %CHOCO_EXE%

echo [%DATE% %TIME%] Chocolatey found: %CHOCO_EXE%

REM ============================================================
REM Install OpenCode Desktop
REM ============================================================

echo.
echo ============================================================
echo Installing OpenCode Desktop...
echo ============================================================
echo.

"%CHOCO_EXE%" install opencode-desktop --yes

if errorlevel 1 (
    echo WARNING: OpenCode installation returned an error.
    echo [%DATE% %TIME%] OpenCode installation failed
) else (
    echo OpenCode Desktop installed.
    echo [%DATE% %TIME%] OpenCode installed
)

REM ============================================================
REM Install GitHub Desktop
REM ============================================================

echo.
echo ============================================================
echo Installing GitHub Desktop...
echo ============================================================
echo.

"%CHOCO_EXE%" install github-desktop --yes

if errorlevel 1 (
    echo WARNING: GitHub Desktop installation returned an error.
    echo [%DATE% %TIME%] GitHub Desktop installation failed
) else (
    echo GitHub Desktop installed.
    echo [%DATE% %TIME%] GitHub Desktop installed
)

REM ============================================================
REM Install IntelliJ IDEA Community
REM ============================================================

echo.
echo ============================================================
echo Installing IntelliJ IDEA Community...
echo ============================================================
echo.

"%CHOCO_EXE%" install intellijidea-community --yes

if errorlevel 1 (
    echo WARNING: IntelliJ IDEA installation returned an error.
    echo [%DATE% %TIME%] IntelliJ IDEA installation failed
) else (
    echo IntelliJ IDEA Community installed.
    echo [%DATE% %TIME%] IntelliJ IDEA installed
)

REM ============================================================
REM Install Ghidra
REM ============================================================

echo.
echo ============================================================
echo Installing Ghidra...
echo ============================================================
echo.

"%CHOCO_EXE%" install ghidra --yes
if errorlevel 1 (
    echo WARNING: Ghidra installation returned an error.
    echo [%DATE% %TIME%] Ghidra installation failed
) else (
    echo Ghidra installed.
    echo [%DATE% %TIME%] Ghidra installed
)

REM ============================================================
REM Refresh PATH
REM ============================================================

echo.
echo Refreshing environment...

set "PATH=%PATH%;%ProgramData%\chocolatey\bin"

REM ============================================================
REM Find OpenCode
REM ============================================================

echo.
echo ============================================================
echo Starting OpenCode Desktop...
echo ============================================================
echo.

set "OPENCODE_EXE="

for /f "delims=" %%A in ('where opencode.exe 2^>nul') do (
    if not defined OPENCODE_EXE set "OPENCODE_EXE=%%A"
)

if not defined OPENCODE_EXE if exist "%ProgramFiles%\OpenCode\OpenCode.exe" (
    set "OPENCODE_EXE=%ProgramFiles%\OpenCode\OpenCode.exe"
)

if not defined OPENCODE_EXE if exist "%LOCALAPPDATA%\Programs\OpenCode\OpenCode.exe" (
    set "OPENCODE_EXE=%LOCALAPPDATA%\Programs\OpenCode\OpenCode.exe"
)

if defined OPENCODE_EXE (
    echo Starting:
    echo %OPENCODE_EXE%
    start "" "%OPENCODE_EXE%"
    echo [%DATE% %TIME%] OpenCode started
) else (
    echo OpenCode executable not found.
    echo [%DATE% %TIME%] OpenCode executable not found
)

REM ============================================================
REM Find GitHub Desktop
REM ============================================================

echo.
echo ============================================================
echo Starting GitHub Desktop...
echo ============================================================
echo.

set "GITHUB_EXE="

if exist "%ProgramFiles%\GitHub Desktop\GitHubDesktop.exe" (
    set "GITHUB_EXE=%ProgramFiles%\GitHub Desktop\GitHubDesktop.exe"
)

if not defined GITHUB_EXE if exist "%LOCALAPPDATA%\GitHubDesktop\GitHubDesktop.exe" (
    set "GITHUB_EXE=%LOCALAPPDATA%\GitHubDesktop\GitHubDesktop.exe"
)

if not defined GITHUB_EXE if exist "%ProgramFiles(x86)%\GitHub Desktop\GitHubDesktop.exe" (
    set "GITHUB_EXE=%ProgramFiles(x86)%\GitHub Desktop\GitHubDesktop.exe"
)

if defined GITHUB_EXE (
    echo Starting:
    echo %GITHUB_EXE%
    start "" "%GITHUB_EXE%"
    echo [%DATE% %TIME%] GitHub Desktop started
) else (
    echo GitHub Desktop executable not found.
    echo [%DATE% %TIME%] GitHub Desktop executable not found
)

REM ============================================================
REM Find IntelliJ IDEA
REM ============================================================

echo.
echo ============================================================
echo Starting IntelliJ IDEA...
echo ============================================================
echo.

set "IDEA_EXE="

for /d %%A in (
    "%ProgramFiles%\JetBrains\IntelliJ IDEA*"
    "%ProgramFiles%\JetBrains\IntelliJ IDEA Community Edition*"
) do (
    if exist "%%~A\bin\idea64.exe" (
        if not defined IDEA_EXE set "IDEA_EXE=%%~A\bin\idea64.exe"
    )
)

if not defined IDEA_EXE (
    for /d %%A in (
        "%LOCALAPPDATA%\Programs\IntelliJ IDEA*"
        "%LOCALAPPDATA%\Programs\IntelliJ IDEA Community Edition*"
    ) do (
        if exist "%%~A\bin\idea64.exe" (
            if not defined IDEA_EXE set "IDEA_EXE=%%~A\bin\idea64.exe"
        )
    )
)

if defined IDEA_EXE (
    echo Starting:
    echo %IDEA_EXE%
    start "" "%IDEA_EXE%"
    echo [%DATE% %TIME%] IntelliJ IDEA started
) else (
    echo IntelliJ IDEA executable not found.
    echo [%DATE% %TIME%] IntelliJ IDEA executable not found
)

REM ============================================================
REM Finish
REM ============================================================

echo.
echo ============================================================
echo Installation/startup completed.
echo ============================================================
echo.
echo Log:
echo %LOG_FILE%
echo.

echo [%DATE% %TIME%] Login script completed

exit /b 0
