param([string]$TargetUser = "ServerPremium")

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

$jdk21 = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\21.0.12-101.0\x64"
if (Test-Path $jdk21) {
    [Environment]::SetEnvironmentVariable("GHIDRA_JAVA_HOME", $jdk21, "User")
    try {
        [Environment]::SetEnvironmentVariable("GHIDRA_JAVA_HOME", $jdk21, "Machine")
    } catch {}
}

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
        Write-Host "Created Ghidra shortcut." -ForegroundColor Green
    }
}
