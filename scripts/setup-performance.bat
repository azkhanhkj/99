@echo off
setlocal EnableExtensions EnableDelayedExpansion

title Premium Server - Setup Performance

echo [*] Adding Defender exclusions for paths and processes...
powershell.exe -NoProfile -ExecutionPolicy Bypass -Command ^
    "$paths = @('D:\','C:\hostedtoolcache','C:\Users\ServerPremium','C:\ProgramData\chocolatey','C:\Cloudflared');" ^
    "foreach ($p in $paths) { if (Test-Path $p) { Add-MpPreference -ExclusionPath $p -ErrorAction SilentlyContinue } };" ^
    "$procs = @('java.exe','javaw.exe','node.exe','bun.exe','code.exe','git.exe');" ^
    "foreach ($pr in $procs) { Add-MpPreference -ExclusionProcess $pr -ErrorAction SilentlyContinue }"

echo [*] Applying visual effects and font smoothing tweaks...
reg add "HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" /v VisualFXSetting /t REG_DWORD /d 2 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop\WindowMetrics" /v MinAnimate /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v MenuShowDelay /t REG_SZ /d 0 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v FontSmoothing /t REG_SZ /d 2 /f >nul 2>&1
reg add "HKCU\Control Panel\Desktop" /v FontSmoothingType /t REG_DWORD /d 2 /f >nul 2>&1

echo [*] System performance and Defender exclusions configured.
exit /b 0
