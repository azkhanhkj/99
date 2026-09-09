@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Uninstaller

echo =======================================================
echo          PREMIUM SERVER - CLEANUP AND UNINSTALLER
echo =======================================================

echo [1/5] Stopping and disabling unused background services...
for %%s in (docker W3SVC SQLWriter MySQL postgresql-x64-14 MongoDB FabricHostSvc Apache nginx) do (
    sc stop "%%s" >nul 2>&1
    sc config "%%s" start= disabled >nul 2>&1
)

echo [2/5] Uninstalling standalone applications (MSI / EXE)...
:: Azure Cosmos DB Emulator (~2.5 GB)
start /wait msiexec.exe /x {CB0238CA-3B36-47AB-86FD-D60F4C47607A} /qn /norestart >nul 2>&1

:: MongoDB 7.0 & Mongo Shell (~2 GB)
start /wait msiexec.exe /x {0BA99F68-DC51-49CE-83E5-9DDFB2892CA9} /qn /norestart >nul 2>&1
start /wait msiexec.exe /x {E9914851-8DAC-4F89-A189-BD56D5C5BAC4} /qn /norestart >nul 2>&1

:: MySQL Server 8.0 (~550 MB)
start /wait msiexec.exe /x {98F56C49-2C6F-45B6-B086-F0B55794FDD8} /qn /norestart >nul 2>&1

:: Epic Games Launcher & Epic Online Services (~600 MB)
start /wait msiexec.exe /x {C5C3EE71-4047-4144-946E-18D500510CB5} /qn /norestart >nul 2>&1
start /wait msiexec.exe /x {5122B8BC-D6DF-48FF-8D4E-15A63EEC5073} /qn /norestart >nul 2>&1

:: Unity Hub (~565 MB)
if exist "%ProgramFiles%\Unity Hub\Uninstall Unity Hub.exe" (
    start /wait "" "%ProgramFiles%\Unity Hub\Uninstall Unity Hub.exe" /allusers /S >nul 2>&1
)

:: PostgreSQL 14 (~870 MB)
if exist "%ProgramFiles%\PostgreSQL\14\uninstall-postgresql.exe" (
    start /wait "" "%ProgramFiles%\PostgreSQL\14\uninstall-postgresql.exe" --mode unattended >nul 2>&1
)

echo [3/5] Uninstalling unnecessary Chocolatey packages...
choco feature enable -n allowGlobalConfirmation >nul 2>&1
set "CHOCO_PKGS=ant apache-httpd aria2 awscli azcopy10 bazel bicep composer gradle hg imagemagick imagemagick.app InnoSetup julia kubernetes-cli kubernetes-helm llvm Minikube nginx nsis nsis.install nssm packer php pulumi R.Project rtools sbt strawberryperl swig Temurin17 Temurin8 tortoisesvn wixtoolset"
choco uninstall %CHOCO_PKGS% --yes --no-progress --no-color >nul 2>&1

echo [4/5] Purging heavy unused SDKs and toolchain directories...
:: Android SDK / NDK (~20-30 GB)
rmdir /s /q "C:\Android" >nul 2>&1
rmdir /s /q "%ProgramFiles(x86)%\Android" >nul 2>&1
rmdir /s /q "%ProgramFiles%\Android" >nul 2>&1

:: Haskell GHC / Cabal / Stack (~11 GB)
rmdir /s /q "C:\ghcup" >nul 2>&1

:: Julia, Miniconda, Perl, R (~6 GB)
rmdir /s /q "C:\Julia" >nul 2>&1
rmdir /s /q "C:\Miniconda" >nul 2>&1
rmdir /s /q "C:\Strawberry" >nul 2>&1
rmdir /s /q "C:\rtools45" >nul 2>&1
rmdir /s /q "%ProgramFiles%\R" >nul 2>&1

:: Test drivers & Cloud CLIs
rmdir /s /q "C:\SeleniumWebDrivers" >nul 2>&1
rmdir /s /q "C:\selenium" >nul 2>&1
rmdir /s /q "C:\aliyun-cli" >nul 2>&1
rmdir /s /q "C:\cobertura-2.1.1" >nul 2>&1

:: Leftover database and launcher directories
rmdir /s /q "%ProgramFiles%\Azure Cosmos DB Emulator" >nul 2>&1
rmdir /s /q "%ProgramFiles%\MongoDB" >nul 2>&1
rmdir /s /q "%ProgramFiles%\MySQL" >nul 2>&1
rmdir /s /q "%ProgramFiles%\PostgreSQL" >nul 2>&1
rmdir /s /q "C:\PostgreSQL" >nul 2>&1
rmdir /s /q "%ProgramFiles(x86)%\Epic Games" >nul 2>&1
rmdir /s /q "%ProgramFiles%\Unity Hub" >nul 2>&1

echo [5/5] Cleanup complete. Disk space recovered!
exit /b 0