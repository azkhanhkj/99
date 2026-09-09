# setup-performance.ps1 - Tối ưu Defender exclusions và hiệu năng hiển thị RDP
Write-Host "=== Tối ưu hóa Windows Defender & Hiệu năng RDP ===" -ForegroundColor Cyan

# 1. Thêm Windows Defender Exclusions để tăng tốc I/O và giảm ngốn CPU khi compile
$exclusions = @(
    "D:\",
    "C:\hostedtoolcache",
    "C:\Users\ServerPremium",
    "C:\ProgramData\chocolatey",
    "C:\Cloudflared"
)

foreach ($path in $exclusions) {
    if (Test-Path $path) {
        Write-Host "Adding Defender path exclusion: $path"
        Add-MpPreference -ExclusionPath $path -ErrorAction SilentlyContinue
    }
}

$procExclusions = @("java.exe", "javaw.exe", "node.exe", "bun.exe", "code.exe", "git.exe")
foreach ($proc in $procExclusions) {
    Write-Host "Adding Defender process exclusion: $proc"
    Add-MpPreference -ExclusionProcess $proc -ErrorAction SilentlyContinue
}

# 2. Tối ưu Registry cho RDP (giảm độ trễ, tắt visual animation nặng nhưng giữ font nét)
Write-Host "Tối ưu Registry cho kết nối RDP..."
# VisualFXSetting = 2 (Custom/Best Performance)
if (-not (Test-Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects")) {
    New-Item -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Force | Out-Null
}
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue

# Tắt Animation Windows
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -ErrorAction SilentlyContinue

# Bật ClearType Font Smoothing (cho text hiển thị rõ nét không bị nhòe)
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingType" -Value 2 -ErrorAction SilentlyContinue

Write-Host "=== Hoàn thành tối ưu hệ thống ===" -ForegroundColor Green
