@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Setup PowerShell Profile

set "TARGET_USER=%~1"
if "%TARGET_USER%"=="" set "TARGET_USER=ServerPremium"

echo [*] Configuring PowerShell profile for %TARGET_USER%...

set "USER_DIR=C:\Users\%TARGET_USER%"
if not exist "%USER_DIR%" set "USER_DIR=%USERPROFILE%"

set "DIR1=%USER_DIR%\Documents\PowerShell"
set "DIR2=%USER_DIR%\Documents\WindowsPowerShell"

if not exist "%DIR1%" mkdir "%DIR1%" >nul 2>&1
if not exist "%DIR2%" mkdir "%DIR2%" >nul 2>&1

set "TMP_PROFILE=%TEMP%\profile_temp_%RANDOM%.ps1"

> "%TMP_PROFILE%" echo function set-java {
>> "%TMP_PROFILE%" echo     [CmdletBinding()]
>> "%TMP_PROFILE%" echo     param(
>> "%TMP_PROFILE%" echo         [Parameter(Mandatory=$true, Position=0)]
>> "%TMP_PROFILE%" echo         [ValidateSet("8", "11", "17", "21", "25")]
>> "%TMP_PROFILE%" echo         [string]$Version
>> "%TMP_PROFILE%" echo     )
>> "%TMP_PROFILE%" echo.
>> "%TMP_PROFILE%" echo     $jdkMap = @{
>> "%TMP_PROFILE%" echo         "8"  = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\8.0.504-1\x64"
>> "%TMP_PROFILE%" echo         "11" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\11.0.32-101\x64"
>> "%TMP_PROFILE%" echo         "17" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64"
>> "%TMP_PROFILE%" echo         "21" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\21.0.12-101.0\x64"
>> "%TMP_PROFILE%" echo         "25" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-101.0\x64"
>> "%TMP_PROFILE%" echo     }
>> "%TMP_PROFILE%" echo.
>> "%TMP_PROFILE%" echo     $targetJdk = $jdkMap[$Version]
>> "%TMP_PROFILE%" echo     if (-not (Test-Path $targetJdk)) {
>> "%TMP_PROFILE%" echo         Write-Host "JDK not found at $targetJdk" -ForegroundColor Red
>> "%TMP_PROFILE%" echo         return
>> "%TMP_PROFILE%" echo     }
>> "%TMP_PROFILE%" echo.
>> "%TMP_PROFILE%" echo     $env:JAVA_HOME = $targetJdk
>> "%TMP_PROFILE%" echo     [Environment]::SetEnvironmentVariable("JAVA_HOME", $targetJdk, "User")
>> "%TMP_PROFILE%" echo.    
>> "%TMP_PROFILE%" echo     $pathItems = ($env:Path -split ';') ^| Where-Object { 
>> "%TMP_PROFILE%" echo         $_ -and ($_ -notmatch 'Java_Temurin-Hotspot_jdk') -and ($_ -notmatch 'Eclipse Adoptium') 
>> "%TMP_PROFILE%" echo     }
>> "%TMP_PROFILE%" echo     $env:Path = "$targetJdk\bin;" + ($pathItems -join ';')
>> "%TMP_PROFILE%" echo.
>> "%TMP_PROFILE%" echo     Write-Host "Switched to Java $Version ($targetJdk)" -ForegroundColor Green
>> "%TMP_PROFILE%" echo     ^& "$targetJdk\bin\java.exe" -version
>> "%TMP_PROFILE%" echo }
>> "%TMP_PROFILE%" echo.
>> "%TMP_PROFILE%" echo Write-Host "Developer environment ready." -ForegroundColor Cyan
>> "%TMP_PROFILE%" echo Write-Host "Use: set-java 8 | 11 | 17 | 21 | 25 to switch JDK" -ForegroundColor Yellow

copy /y "%TMP_PROFILE%" "%DIR1%\Microsoft.PowerShell_profile.ps1" >nul 2>&1
copy /y "%TMP_PROFILE%" "%DIR2%\Microsoft.PowerShell_profile.ps1" >nul 2>&1
del /f /q "%TMP_PROFILE%" >nul 2>&1

set "DEFAULT_JDK=C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64"
if exist "%DEFAULT_JDK%" (
    setx JAVA_HOME "%DEFAULT_JDK%" >nul 2>&1
    setx JAVA_HOME "%DEFAULT_JDK%" /M >nul 2>&1
)

echo [*] PowerShell profile setup complete.
exit /b 0
