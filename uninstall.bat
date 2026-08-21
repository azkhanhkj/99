@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Application Uninstaller

set "TARGET_USER=ServerPremium"

if /I not "%USERNAME%"=="%TARGET_USER%" (
    exit /b 0
)

choco uninstall apache-httpd aria2 hg Minikube nginx nssm packer rtools sbt strawberryperl swig tortoisesvn unzip wixtoolset julia R.Project php composer pulumi bicep bazel azcopy10 awscli kubernetes-cli kubernetes-helm gradle imagemagick imagemagick.app --yes --no-progress
exit /b 0