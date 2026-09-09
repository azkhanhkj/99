param()

$exclusions = @(
    "D:\",
    "C:\hostedtoolcache",
    "C:\Users\ServerPremium",
    "C:\ProgramData\chocolatey",
    "C:\Cloudflared"
)

foreach ($path in $exclusions) {
    if (Test-Path $path) {
        Add-MpPreference -ExclusionPath $path -ErrorAction SilentlyContinue
    }
}

$procExclusions = @("java.exe", "javaw.exe", "node.exe", "bun.exe", "code.exe", "git.exe")
foreach ($proc in $procExclusions) {
    Add-MpPreference -ExclusionProcess $proc -ErrorAction SilentlyContinue
}

if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingType" -Value 2 -ErrorAction SilentlyContinue

Write-Host "System performance and Defender exclusions configured." -ForegroundColor Green
