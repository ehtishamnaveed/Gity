# Gity Windows Installer
# One-command setup for Windows users
# Usage: irm https://raw.githubusercontent.com/ehtishamnaveed/Gity/master/install.ps1 | iex

$InstallDir = Join-Path $env:LOCALAPPDATA "Programs\Gity"
$CacheDir = Join-Path $env:APPDATA "gity"
$GityUrl = "https://raw.githubusercontent.com/ehtishamnaveed/Gity/master"

function Write-Step {
    param([string]$Text)
    Write-Host "==> $Text" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Text)
    Write-Host "    [OK] $Text" -ForegroundColor Green
}

function Write-Warn {
    param([string]$Text)
    Write-Host "    [WARN] $Text" -ForegroundColor Yellow
}

function Write-Err {
    param([string]$Text)
    Write-Host "    [FAIL] $Text" -ForegroundColor Red
}

function Check-Command {
    param([string]$Name)
    $null -ne (Get-Command $Name -ErrorAction SilentlyContinue)
}

function Install-WithWinget {
    param(
        [string]$Name,
        [string]$WingetId
    )
    
    if (Check-Command $Name) {
        Write-Success "$Name already installed"
        return $true
    }
    
    Write-Step "Installing $Name via winget..."
    
    try {
        $result = winget install -e --id $WingetId --silent --accept-source-agreements 2>&1
        
        if ($LASTEXITCODE -eq 0) {
            Write-Success "$Name installed successfully"
            # Refresh PATH
            $env:PATH = [System.Environment]::GetEnvironmentVariable("PATH", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH", "User")
            return $true
        } else {
            Write-Warn "winget install failed for $Name (exit code: $LASTEXITCODE)"
            return $false
        }
    } catch {
        Write-Warn "winget error: $_"
        return $false
    }
}

function Add-ToPath {
    param([string]$PathToAdd)
    
    $currentPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
    
    if ($currentPath -split ';' | Where-Object { $_ -eq $PathToAdd }) {
        Write-Success "Already in PATH: $PathToAdd"
        return $true
    }
    
    try {
        $newPath = "$currentPath;$PathToAdd"
        [System.Environment]::SetEnvironmentVariable("PATH", $newPath, "User")
        $env:PATH = "$env:PATH;$PathToAdd"
        Write-Success "Added to PATH: $PathToAdd"
        return $true
    } catch {
        Write-Err "Failed to add to PATH: $_"
        return $false
    }
}

function Download-Gity {
    Write-Step "Downloading Gity..."
    
    if (!(Test-Path $InstallDir)) {
        New-Item -ItemType Directory -Path $InstallDir -Force | Out-Null
    }
    
    $gityFile = Join-Path $InstallDir "gity.ps1"
    
    try {
        Invoke-WebRequest -Uri "$GityUrl/gity.ps1" -UseBasicParsing -OutFile $gityFile
        Write-Success "Gity downloaded to $InstallDir"
        return $true
    } catch {
        Write-Err "Failed to download Gity: $_"
        return $false
    }
}

function Save-Version {
    try {
        $version = (Invoke-WebRequest -Uri "$GityUrl/VERSION" -UseBasicParsing -TimeoutSec 5).Content.Trim()
        if (!(Test-Path $CacheDir)) {
            New-Item -ItemType Directory -Path $CacheDir -Force | Out-Null
        }
        Set-Content -Path (Join-Path $CacheDir "VERSION") -Value $version -Force
        Write-Success "Version saved: $version"
    } catch {
        Write-Warn "Could not fetch version info (will use default)"
    }
}

# ============================================================
# MAIN INSTALL
# ============================================================

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  GITY - Windows Installer v1.0.0" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Check winget
Write-Step "Checking winget..."
if (!(Check-Command "winget")) {
    Write-Err "winget not found!"
    Write-Host ""
    Write-Host "Please install winget first:" -ForegroundColor Yellow
    Write-Host "  1. Open Microsoft Store" -ForegroundColor Gray
    Write-Host "  2. Search for 'App Installer'" -ForegroundColor Gray
    Write-Host "  3. Install it" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or download from: https://aka.ms/getwinget" -ForegroundColor Gray
    Write-Host ""
    exit 1
}
Write-Success "winget found"

# Install dependencies
Write-Host ""
Write-Step "Checking dependencies..."
Write-Host ""

$deps = @(
    @{Name = "git"; WingetId = "Git.Git"},
    @{Name = "fzf"; WingetId = "junegunn.fzf"},
    @{Name = "gh"; WingetId = "GitHub.cli"},
    @{Name = "lazygit"; WingetId = "JesseDuffield.lazygit"}
)

$failedDeps = @()

foreach ($dep in $deps) {
    if (!(Install-WithWinget -Name $dep.Name -WingetId $dep.WingetId)) {
        $failedDeps += $dep
    }
}

Write-Host ""

if ($failedDeps.Count -gt 0) {
    Write-Host ""
    Write-Warn "Some dependencies failed to install:"
    foreach ($dep in $failedDeps) {
        Write-Host "    - $($dep.Name)" -ForegroundColor Red
    }
    Write-Host ""
    Write-Host "Try these steps:" -ForegroundColor Yellow
    Write-Host "  1. Run PowerShell as Administrator" -ForegroundColor Gray
    Write-Host "  2. Run: winget source reset --force" -ForegroundColor Gray
    Write-Host "  3. Run this installer again" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Or install manually:" -ForegroundColor Yellow
    foreach ($dep in $failedDeps) {
        Write-Host "    winget install -e --id $($dep.WingetId)" -ForegroundColor Gray
    }
    Write-Host ""
}

# Download Gity
if (!(Download-Gity)) {
    exit 1
}

# Add to PATH
Add-ToPath $InstallDir

# Save version
Save-Version

# Success message
Write-Host ""
Write-Host "========================================" -ForegroundColor Green
Write-Host "  INSTALLATION COMPLETE" -ForegroundColor White
Write-Host "========================================" -ForegroundColor Green
Write-Host ""
Write-Host "Installed to: $InstallDir" -ForegroundColor White
Write-Host ""
Write-Host "To run Gity:" -ForegroundColor Cyan
Write-Host "  1. Open a NEW terminal" -ForegroundColor Gray
Write-Host "  2. Type: gity" -ForegroundColor Yellow
Write-Host ""
Write-Host "Or run directly:" -ForegroundColor Cyan
Write-Host "  pwsh -File `"$InstallDir\gity.ps1`"" -ForegroundColor Yellow
Write-Host ""
