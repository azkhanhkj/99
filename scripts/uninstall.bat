@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Uninstaller

echo [1/3] Stopping unused background services...
for %%s in (docker W3SVC SQLWriter MySQL PostgreSQL) do (
    sc stop "%%s" >nul 2>&1
    sc config "%%s" start= disabled >nul 2>&1
)

echo [2/3] Uninstalling unnecessary Chocolatey packages...
choco uninstall ant apache-httpd aria2 awscli azcopy10 bazel bicep composer gradle hg imagemagick imagemagick.app julia kubernetes-cli kubernetes-helm Minikube nginx nssm packer php pulumi R.Project rtools sbt strawberryperl swig Temurin17 Temurin8 tortoisesvn wixtoolset --yes --no-progress

echo [3/3] Cleanup complete.
exit /b 0