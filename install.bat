@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Application Installer

set "TARGET_USER=ServerPremium"

if /I not "%USERNAME%"=="%TARGET_USER%" (
    exit /b 0
)

choco feature enable -n allowGlobalConfirmation

call recaf.bat

choco install intellijidea-community --version 2024.1.5 --yes
choco install opencode github-desktop temurin17 temurin8 ghidra --yes
choco uninstall apache-httpd aria2 hg Minikube nginx nssm packer rtools sbt strawberryperl swig tortoisesvn unzip wixtoolset julia R.Project php composer pulumi bicep bazel azcopy10 awscli kubernetes-cli kubernetes-helm gradle imagemagick imagemagick.app --yes --no-progress

:: Install Bun using the official installer
powershell -NoProfile -ExecutionPolicy Bypass -Command "irm https://bun.sh/install.ps1 | iex"

exit /b 0