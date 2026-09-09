# Kế Hoạch Triển Khai: Tối Ưu Tốc Độ Setup & Môi Trường Viết Code

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Tối ưu hóa toàn diện thời gian setup runner Windows RDP (zero-wait logon), tận dụng JDK toolcache có sẵn, cải thiện hiệu năng RDP & biên dịch với Defender exclusions, và cung cấp tiện ích chuyển đổi Java (`set-java`) cùng Desktop shortcuts.

**Architecture:** Tách biệt các tác vụ thành các module độc lập: tối ưu hệ thống (`setup-performance.ps1`), cấu hình profile & switch Java (`setup-profile.ps1`), cài đặt công cụ & tạo shortcut (`install.bat` tối ưu), và tích hợp pre-install vào GitHub Actions workflow (`blank.yml`, `blank2.yml`).

**Tech Stack:** PowerShell, Windows Batch, GitHub Actions, Windows Defender cmdlets, Chocolatey, Bun.

**Spec:** `docs/superpowers/specs/2026-09-09-speed-setup-and-coding-experience-design.md`

## Global Constraints
- Phải hỗ trợ môi trường Windows Server 2022 runner trên GitHub Actions.
- Tuyệt đối không xóa bỏ hay làm gãy kết nối Cloudflare Tunnel hiện tại (`cloudflared.bat`).
- Đảm bảo các đường dẫn Java trỏ chính xác vào `C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk`.
- Không sử dụng các alias git và ai agent theo yêu cầu của user.

---

### Task 1: Script Tối Ưu Hiệu Năng Hệ Thống & RDP (`setup-performance.ps1`)

**Files:**
- Create: `setup-performance.ps1`

**Interfaces:**
- Consumes: Windows PowerShell Administrator privileges, Defender module, Registry.
- Produces: Hệ thống Windows được thêm exclusion paths & processes, cấu hình Registry tối ưu hiển thị RDP.

- [ ] **Step 1: Tạo file `setup-performance.ps1`**

```powershell
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
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects" -Name "VisualFXSetting" -Value 2 -ErrorAction SilentlyContinue

# Tắt Animation Windows
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop\WindowMetrics" -Name "MinAnimate" -Value "0" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "MenuShowDelay" -Value "0" -ErrorAction SilentlyContinue

# Bật ClearType Font Smoothing (cho text hiển thị rõ nét không bị nhòe)
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothing" -Value "2" -ErrorAction SilentlyContinue
Set-ItemProperty -Path "HKCU:\Control Panel\Desktop" -Name "FontSmoothingType" -Value 2 -ErrorAction SilentlyContinue

Write-Host "=== Hoàn thành tối ưu hệ thống ===" -ForegroundColor Green
```

- [ ] **Step 2: Chạy thử nghiệm `setup-performance.ps1` trong môi trường hiện tại**

Run: `powershell -ExecutionPolicy Bypass -File .\setup-performance.ps1`
Expected: Hoàn thành không có lỗi, xuất hiện thông báo xanh.

- [ ] **Step 3: Commit**

```bash
git add setup-performance.ps1
git commit -m "perf: add setup-performance script for defender and rdp tweaks"
```

---

### Task 2: Cấu Hình PowerShell Profile & Hàm Switch Java (`setup-profile.ps1`)

**Files:**
- Create: `setup-profile.ps1`

**Interfaces:**
- Consumes: Java versions trong `C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk`.
- Produces: File profile PowerShell cho `ServerPremium` hỗ trợ hàm `set-java`.

- [ ] **Step 1: Tạo file `setup-profile.ps1`**

```powershell
# setup-profile.ps1 - Cấu hình Profile PowerShell cho ServerPremium
param(
    [string]$TargetUser = "ServerPremium"
)

Write-Host "=== Cấu hình PowerShell Profile cho $TargetUser ===" -ForegroundColor Cyan

$userProfileDir = "C:\Users\$TargetUser"
if (-not (Test-Path $userProfileDir)) {
    $userProfileDir = $env:USERPROFILE
}

$profileDirs = @(
    "$userProfileDir\Documents\PowerShell",
    "$userProfileDir\Documents\WindowsPowerShell"
)

$profileContent = @'
# Developer Environment Helper Functions

function set-java {
    param([Parameter(Mandatory=$true)][string]$Version)
    $jdkMap = @{
        "8"  = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\8.0.504-1\x64"
        "11" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\11.0.32-101\x64"
        "17" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64"
        "21" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\21.0.12-101.0\x64"
        "25" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-101.0\x64"
    }

    if (-not $jdkMap.ContainsKey($Version)) {
        Write-Host "Phien ban Java khong hop le. Cac lua chon hop le: 8, 11, 17, 21, 25" -ForegroundColor Red
        return
    }

    $targetJdk = $jdkMap[$Version]
    if (-not (Test-Path $targetJdk)) {
        Write-Host "Khong tim thay JDK tai $targetJdk" -ForegroundColor Red
        return
    }

    $env:JAVA_HOME = $targetJdk
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $targetJdk, "User")
    
    # Cap nhat PATH hien tai
    $pathParts = ($env:Path -split ';') | Where-Object { $_ -notmatch 'Java_Temurin-Hotspot_jdk' -and $_ -notmatch 'Eclipse Adoptium' }
    $env:Path = "$targetJdk\bin;" + ($pathParts -join ';')

    Write-Host "Da chuyen sang Java $Version ($targetJdk)" -ForegroundColor Green
    & "$targetJdk\bin\java.exe" -version
}

Write-Host "Developer Environment Ready." -ForegroundColor Cyan
Write-Host "Su dung lenh: set-java 8 | 11 | 17 | 21 | 25 de doi phien ban Java" -ForegroundColor Yellow
'@

foreach ($dir in $profileDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $targetFile = "$dir\Microsoft.PowerShell_profile.ps1"
    Set-Content -Path $targetFile -Value $profileContent -Encoding UTF8
    Write-Host "Da tao Profile tai: $targetFile"
}

Write-Host "=== Hoan tat cau hinh Profile ===" -ForegroundColor Green
```

- [ ] **Step 2: Chạy thử nghiệm `setup-profile.ps1` và kiểm tra hàm `set-java`**

Run: `powershell -ExecutionPolicy Bypass -File .\setup-profile.ps1`
Run test command: `powershell -ExecutionPolicy Bypass -Command ". C:\Users\ServerPremium\Documents\PowerShell\Microsoft.PowerShell_profile.ps1; set-java 17"`
Expected: Thông báo "Da chuyen sang Java 17" và in ra thông tin OpenJDK 17.

- [ ] **Step 3: Commit**

```bash
git add setup-profile.ps1
git commit -m "feat: add setup-profile script with set-java helper"
```

---

### Task 3: Tối Ưu Hóa Cài Đặt Công Cụ & Shortcuts (`install.bat` & `setup-shortcuts.ps1`)

**Files:**
- Create: `setup-shortcuts.ps1`
- Modify: `install.bat`

**Interfaces:**
- Consumes: Pre-installed toolcache JDKs, Bun installer, Chocolatey.
- Produces: Các IDE được cài đặt, JAVA_HOME mặc định hệ thống trỏ JDK 17, shortcuts trên Desktop cho Ghidra, Recaf, IntelliJ, VS Code, Antigravity, GitHub Desktop.

- [ ] **Step 1: Tạo `setup-shortcuts.ps1` để tự động tạo toàn bộ Desktop shortcuts**

```powershell
# setup-shortcuts.ps1 - Tạo Desktop & Start Menu shortcuts cho toàn bộ công cụ dev
param([string]$TargetUser = "ServerPremium")

$ws = New-Object -ComObject WScript.Shell
$desktop = "C:\Users\$TargetUser\Desktop"
if (-not (Test-Path $desktop)) {
    $desktop = [Environment]::GetFolderPath('CommonDesktopDirectory')
}

Write-Host "Creating desktop shortcuts in $desktop..." -ForegroundColor Cyan

# 1. Ghidra Shortcut (liên kết với JDK 17 hoặc 21 từ toolcache)
$ghidraDirs = Get-ChildItem "C:\ProgramData\chocolatey\lib\ghidra\tools" -Filter "ghidra_*" -Directory -ErrorAction SilentlyContinue
if ($ghidraDirs) {
    $ghidraBat = Join-Path $ghidraDirs[0].FullName "ghidraRun.bat"
    if (Test-Path $ghidraBat) {
        $s = $ws.CreateShortcut("$desktop\Ghidra.lnk")
        $s.TargetPath = $ghidraBat
        $s.WorkingDirectory = $ghidraDirs[0].FullName
        $s.Description = "Ghidra Software Reverse Engineering"
        $s.Save()
        Write-Host "Created Ghidra shortcut"
    }
}

# 2. Recaf 4.x Shortcut (nếu có Recaf.jar)
$recafJar = "C:\Program Files\Recaf\Recaf.jar"
$recafIcon = "C:\Program Files\Recaf\Recaf.ico"
$javaw = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-101.0\x64\bin\javaw.exe"
if (Test-Path $recafJar) {
    $s = $ws.CreateShortcut("$desktop\Recaf.lnk")
    $s.TargetPath = $javaw
    $s.Arguments = "-jar `"$recafJar`""
    $s.WorkingDirectory = "C:\Program Files\Recaf"
    if (Test-Path $recafIcon) { $s.IconLocation = "$recafIcon,0" }
    $s.Description = "Recaf Bytecode Editor"
    $s.Save()
    Write-Host "Created Recaf shortcut"
}

# 3. IntelliJ IDEA Shortcut
$ideaExe = (Get-ChildItem "C:\Program Files\JetBrains" -Filter "idea64.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if ($ideaExe -and (Test-Path $ideaExe)) {
    $s = $ws.CreateShortcut("$desktop\IntelliJ IDEA.lnk")
    $s.TargetPath = $ideaExe
    $s.Save()
    Write-Host "Created IntelliJ IDEA shortcut"
}

# 4. VS Code Shortcut
$codeExe = "C:\Program Files\Microsoft VS Code\Code.exe"
if (Test-Path $codeExe) {
    $s = $ws.CreateShortcut("$desktop\Visual Studio Code.lnk")
    $s.TargetPath = $codeExe
    $s.Save()
    Write-Host "Created VS Code shortcut"
}

# 5. Antigravity IDE Shortcut
$antigravityExe = (Get-ChildItem "$env:LOCALAPPDATA\Programs\Antigravity" -Filter "*.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if (-not $antigravityExe) {
    $antigravityExe = (Get-ChildItem "C:\Program Files" -Filter "*antigravity*.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}
if ($antigravityExe -and (Test-Path $antigravityExe)) {
    $s = $ws.CreateShortcut("$desktop\Antigravity IDE.lnk")
    $s.TargetPath = $antigravityExe
    $s.Save()
    Write-Host "Created Antigravity IDE shortcut"
}

Write-Host "Shortcuts created successfully." -ForegroundColor Green
```

- [ ] **Step 2: Cập nhật `install.bat` loại bỏ gói thừa và thiết lập JAVA_HOME**

Sửa file `install.bat`:
- Loại bỏ `temurin17` và `temurin8`.
- Set biến môi trường hệ thống `JAVA_HOME` mặc định là `C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64`.
- Thêm cờ `--no-progress` vào `choco install` để tăng tốc độ cài đặt console.
- Gọi `recaf.bat`.
- Chạy `setup-profile.ps1` và `setup-shortcuts.ps1`.

- [ ] **Step 3: Chạy thử nghiệm và kiểm tra**

Run: `call install.bat`
Expected: Cài đặt hoàn tất nhanh chóng, không có lỗi.

- [ ] **Step 4: Commit**

```bash
git add install.bat setup-shortcuts.ps1
git commit -m "feat: optimize install.bat and add automated desktop shortcuts"
```

---

### Task 4: Cập Nhật GitHub Actions Workflows (`blank.yml` & `blank2.yml`)

**Files:**
- Modify: `.github/workflows/blank.yml`
- Modify: `.github/workflows/blank2.yml`

**Interfaces:**
- Consumes: GitHub Actions runner lifecycle.
- Produces: Cài đặt phần mềm trước khi user login; loại bỏ hoàn toàn tình trạng phải đợi 15 phút sau khi kết nối RDP.

- [ ] **Step 1: Cập nhật `blank.yml`**
Thêm các bước:
1. `System & Performance Optimization` (chạy `setup-performance.ps1`).
2. `Pre-install Software & Setup Tools` (chạy `install.bat` trực tiếp trong workflow runner).
3. Đơn giản hóa hoặc gỡ bỏ `Installer` Scheduled Task để khi login không bị popup cài đặt đè màn hình.

- [ ] **Step 2: Đồng bộ hóa `blank2.yml`**
Đảm bảo `blank2.yml` có cấu trúc giống hệt `blank.yml`.

- [ ] **Step 3: Commit**

```bash
git add .github/workflows/blank.yml .github/workflows/blank2.yml
git commit -m "ci: pre-install dev tools and apply performance tweaks in workflow"
```

---

### Task 5: Kiểm Tra Toàn Diện & Nghiệm Thu (End-to-End Verification)

- [ ] **Step 1: Kiểm tra tính hoạt động của các file script**
  - Chạy `setup-performance.ps1`
  - Chạy `setup-profile.ps1`
  - Chạy `setup-shortcuts.ps1`
  - Chạy `powershell -ExecutionPolicy Bypass -Command "set-java 17; java -version; set-java 8; java -version"`
- [ ] **Step 2: Rà soát git status và diff toàn bộ dự án**
- [ ] **Step 3: Tạo báo cáo tổng kết (walkthrough)**
