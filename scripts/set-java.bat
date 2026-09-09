@echo off

set "VERSION=%~1"
if "%VERSION%"=="" (
    echo Usage: set-java 8 ^| 11 ^| 17 ^| 21 ^| 25
    exit /b 1
)

set "TARGET_JDK="
if "%VERSION%"=="8"  set "TARGET_JDK=%JAVA_HOME_8_X64%"
if "%VERSION%"=="11" set "TARGET_JDK=%JAVA_HOME_11_X64%"
if "%VERSION%"=="17" set "TARGET_JDK=%JAVA_HOME_17_X64%"
if "%VERSION%"=="21" set "TARGET_JDK=%JAVA_HOME_21_X64%"
if "%VERSION%"=="25" set "TARGET_JDK=%JAVA_HOME_25_X64%"

if "%TARGET_JDK%"=="" (
    echo [ERROR] Unsupported Java version: %VERSION%
    echo Available versions: 8, 11, 17, 21, 25
    exit /b 1
)

if not exist "%TARGET_JDK%" (
    echo [ERROR] JDK not found at %TARGET_JDK%
    exit /b 1
)

set "JAVA_HOME=%TARGET_JDK%"
set "PATH=%TARGET_JDK%\bin;%PATH%"
setx JAVA_HOME "%TARGET_JDK%" >nul 2>&1

echo Switched to Java %VERSION%: %TARGET_JDK%
"%TARGET_JDK%\bin\java.exe" -version
exit /b 0
