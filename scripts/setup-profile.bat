@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Setup Profile

set "TARGET_USER=%~1"
if "%TARGET_USER%"=="" set "TARGET_USER=ServerPremium"

echo [*] Configuring environment and profile for %TARGET_USER%...

set "USER_DIR=C:\Users\%TARGET_USER%"
if not exist "%USER_DIR%" set "USER_DIR=%USERPROFILE%"

:: 1. Deploy set-java.bat to PATH locations
set "SET_JAVA_SRC=%~dp0set-java.bat"
if exist "%SET_JAVA_SRC%" (
    if not exist "%USER_DIR%\.bun\bin" mkdir "%USER_DIR%\.bun\bin" >nul 2>&1
    copy /y "%SET_JAVA_SRC%" "%USER_DIR%\.bun\bin\set-java.bat" >nul 2>&1
    copy /y "%SET_JAVA_SRC%" "C:\ProgramData\chocolatey\bin\set-java.bat" >nul 2>&1
    copy /y "%SET_JAVA_SRC%" "C:\Windows\System32\set-java.bat" >nul 2>&1
)

:: 2. Create Command Prompt profile.bat
set "PROFILE_BAT=%USER_DIR%\profile.bat"
> "%PROFILE_BAT%" echo @echo off
>> "%PROFILE_BAT%" echo echo =======================================================
>> "%PROFILE_BAT%" echo echo Developer environment ready.
>> "%PROFILE_BAT%" echo echo Use: set-java 8 ^^^| 11 ^^^| 17 ^^^| 21 ^^^| 25 to switch JDK
>> "%PROFILE_BAT%" echo echo =======================================================

:: Register profile.bat to AutoRun in Command Prompt
reg add "HKCU\Software\Microsoft\Command Processor" /v AutoRun /t REG_SZ /d "\"%PROFILE_BAT%\"" /f >nul 2>&1

:: 3. Set default JAVA_HOME to Java 17
set "DEFAULT_JDK=%JAVA_HOME_17_X64%"
if exist "%DEFAULT_JDK%" (
    setx JAVA_HOME "%DEFAULT_JDK%" >nul 2>&1
    setx JAVA_HOME "%DEFAULT_JDK%" /M >nul 2>&1
)

:: 4. Clean up legacy .ps1 profiles
del /f /q "%USER_DIR%\Documents\PowerShell\Microsoft.PowerShell_profile.ps1" >nul 2>&1
del /f /q "%USER_DIR%\Documents\WindowsPowerShell\Microsoft.PowerShell_profile.ps1" >nul 2>&1

echo [*] Profile and set-java command configured successfully.
exit /b 0
