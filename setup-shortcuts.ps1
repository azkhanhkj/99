# setup-shortcuts.ps1 - Tạo Desktop & Start Menu shortcuts cho các công cụ dev
param([string]$TargetUser = "ServerPremium")

Write-Host "=== Tao Shortcuts tren Desktop cho $TargetUser ===" -ForegroundColor Cyan

$ws = New-Object -ComObject WScript.Shell
$desktopPaths = @(
    "C:\Users\$TargetUser\Desktop",
    [Environment]::GetFolderPath('CommonDesktopDirectory')
) | Where-Object { Test-Path $_ } | Select-Object -Unique

function Save-ShortcutSafely($shortcut) {
    try {
        $shortcut.Save()
    } catch {}
}

# 1. Cấu hình GHIDRA_JAVA_HOME sang Java 21 (Ghidra 12 yêu cầu Java >= 21)
$jdk21 = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\21.0.12-101.0\x64"
if (Test-Path $jdk21) {
    [Environment]::SetEnvironmentVariable("GHIDRA_JAVA_HOME", $jdk21, "User")
    try {
        [Environment]::SetEnvironmentVariable("GHIDRA_JAVA_HOME", $jdk21, "Machine")
    } catch {}
    Write-Host "Da thiet lap GHIDRA_JAVA_HOME -> Java 21" -ForegroundColor Green
}

# 2. Ghidra Shortcut
$ghidraDirs = Get-ChildItem "C:\ProgramData\chocolatey\lib\ghidra\tools" -Filter "ghidra_*" -Directory -ErrorAction SilentlyContinue
if ($ghidraDirs) {
    $ghidraRoot = $ghidraDirs[0].FullName
    $ghidraBat = Join-Path $ghidraRoot "ghidraRun.bat"
    $ghidraIcon = Join-Path $ghidraRoot "support\ghidra.ico"
    if (Test-Path $ghidraBat) {
        foreach ($dp in $desktopPaths) {
            $s = $ws.CreateShortcut("$dp\Ghidra.lnk")
            $s.TargetPath = $ghidraBat
            $s.WorkingDirectory = $ghidraRoot
            if (Test-Path $ghidraIcon) { $s.IconLocation = "$ghidraIcon,0" }
            $s.Description = "Ghidra Software Reverse Engineering Framework"
            Save-ShortcutSafely $s
        }
        Write-Host "Created Ghidra shortcut" -ForegroundColor Green
    }
}

# 3. Recaf 4.x Shortcut
$recafJar = "C:\Program Files\Recaf\Recaf.jar"
$recafIcon = "C:\Program Files\Recaf\Recaf.ico"
$jdk25Javaw = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-101.0\x64\bin\javaw.exe"
if (Test-Path $recafJar) {
    foreach ($dp in $desktopPaths) {
        $s = $ws.CreateShortcut("$dp\Recaf.lnk")
        $s.TargetPath = $jdk25Javaw
        $s.Arguments = "-jar `"$recafJar`""
        $s.WorkingDirectory = "C:\Program Files\Recaf"
        if (Test-Path $recafIcon) { $s.IconLocation = "$recafIcon,0" }
        $s.Description = "Recaf 4.x Bytecode Editor"
        Save-ShortcutSafely $s
    }
    Write-Host "Created Recaf shortcut" -ForegroundColor Green
}

# 4. IntelliJ IDEA Shortcut
$ideaExe = (Get-ChildItem "C:\Program Files\JetBrains" -Filter "idea64.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
if ($ideaExe -and (Test-Path $ideaExe)) {
    foreach ($dp in $desktopPaths) {
        $s = $ws.CreateShortcut("$dp\IntelliJ IDEA.lnk")
        $s.TargetPath = $ideaExe
        $s.WorkingDirectory = [System.IO.Path]::GetDirectoryName($ideaExe)
        $s.Description = "IntelliJ IDEA Community"
        Save-ShortcutSafely $s
    }
    Write-Host "Created IntelliJ IDEA shortcut" -ForegroundColor Green
}

# 5. VS Code Shortcut
$codeExe = "C:\Program Files\Microsoft VS Code\Code.exe"
if (Test-Path $codeExe) {
    foreach ($dp in $desktopPaths) {
        $s = $ws.CreateShortcut("$dp\Visual Studio Code.lnk")
        $s.TargetPath = $codeExe
        $s.Description = "Visual Studio Code"
        Save-ShortcutSafely $s
    }
    Write-Host "Created Visual Studio Code shortcut" -ForegroundColor Green
}

# 6. Antigravity IDE Shortcut
$antigravityPaths = @(
    "C:\Users\$TargetUser\AppData\Local\Programs\Antigravity IDE\Antigravity IDE.exe",
    "$env:LOCALAPPDATA\Programs\Antigravity IDE\Antigravity IDE.exe"
)
$antigravityExe = $antigravityPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if (-not $antigravityExe) {
    $antigravityExe = (Get-ChildItem "C:\Program Files" -Filter "*antigravity*.exe" -Recurse -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
}
if ($antigravityExe -and (Test-Path $antigravityExe)) {
    foreach ($dp in $desktopPaths) {
        $s = $ws.CreateShortcut("$dp\Antigravity IDE.lnk")
        $s.TargetPath = $antigravityExe
        $s.WorkingDirectory = [System.IO.Path]::GetDirectoryName($antigravityExe)
        $s.Description = "Antigravity IDE"
        Save-ShortcutSafely $s
    }
    Write-Host "Created Antigravity IDE shortcut" -ForegroundColor Green
}

# 7. GitHub Desktop Shortcut
$gitHubDesktopPaths = @(
    "C:\Users\$TargetUser\AppData\Local\GitHubDesktop\GitHubDesktop.exe",
    "$env:LOCALAPPDATA\GitHubDesktop\GitHubDesktop.exe"
)
$gitHubDesktopExe = $gitHubDesktopPaths | Where-Object { Test-Path $_ } | Select-Object -First 1
if ($gitHubDesktopExe -and (Test-Path $gitHubDesktopExe)) {
    foreach ($dp in $desktopPaths) {
        $s = $ws.CreateShortcut("$dp\GitHub Desktop.lnk")
        $s.TargetPath = $gitHubDesktopExe
        $s.WorkingDirectory = [System.IO.Path]::GetDirectoryName($gitHubDesktopExe)
        $s.Description = "GitHub Desktop"
        Save-ShortcutSafely $s
    }
    Write-Host "Created GitHub Desktop shortcut" -ForegroundColor Green
}

Write-Host "=== Hoan tat tao Shortcuts ===" -ForegroundColor Green
