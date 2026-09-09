param(
    [string]$TargetUser = "ServerPremium"
)

Write-Host "Configuring PowerShell profile for $TargetUser..." -ForegroundColor Cyan

$userProfileDir = "C:\Users\$TargetUser"
if (-not (Test-Path $userProfileDir)) {
    $userProfileDir = $env:USERPROFILE
}

$profileDirs = @(
    "$userProfileDir\Documents\PowerShell",
    "$userProfileDir\Documents\WindowsPowerShell"
)

$profileContent = @'
function set-java {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, Position=0)]
        [ValidateSet("8", "11", "17", "21", "25")]
        [string]$Version
    )

    $jdkMap = @{
        "8"  = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\8.0.504-1\x64"
        "11" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\11.0.32-101\x64"
        "17" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64"
        "21" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\21.0.12-101.0\x64"
        "25" = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\25.0.4-101.0\x64"
    }

    $targetJdk = $jdkMap[$Version]
    if (-not (Test-Path $targetJdk)) {
        Write-Host "JDK not found at $targetJdk" -ForegroundColor Red
        return
    }

    $env:JAVA_HOME = $targetJdk
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $targetJdk, "User")
    
    $pathItems = ($env:Path -split ';') | Where-Object { 
        $_ -and ($_ -notmatch 'Java_Temurin-Hotspot_jdk') -and ($_ -notmatch 'Eclipse Adoptium') 
    }
    $env:Path = "$targetJdk\bin;" + ($pathItems -join ';')

    Write-Host "Switched to Java $Version ($targetJdk)" -ForegroundColor Green
    & "$targetJdk\bin\java.exe" -version
}

Write-Host "Developer environment ready." -ForegroundColor Cyan
Write-Host "Use: set-java 8 | 11 | 17 | 21 | 25 to switch JDK" -ForegroundColor Yellow
'@

foreach ($dir in $profileDirs) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir -Force | Out-Null
    }
    $targetFile = "$dir\Microsoft.PowerShell_profile.ps1"
    Set-Content -Path $targetFile -Value $profileContent -Encoding UTF8
    Write-Host "Profile created at: $targetFile"
}

$defaultJdk17 = "C:\hostedtoolcache\windows\Java_Temurin-Hotspot_jdk\17.0.20-101\x64"
if (Test-Path $defaultJdk17) {
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $defaultJdk17, "User")
    try {
        [Environment]::SetEnvironmentVariable("JAVA_HOME", $defaultJdk17, "Machine")
        Write-Host "Machine JAVA_HOME set to Java 17." -ForegroundColor Green
    } catch {
        Write-Host "User JAVA_HOME set to Java 17." -ForegroundColor Green
    }
}

Write-Host "PowerShell profile setup complete." -ForegroundColor Green
