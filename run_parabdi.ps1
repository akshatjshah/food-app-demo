# ============================================================================
# run_parabdi.ps1 - Permanent, IP-independent local Android development.
# ----------------------------------------------------------------------------
# One command sets up everything for ANY authorized USB Android phone:
#   1. Detects the connected Android device via ADB (no manual device ID)
#   2. Runs `adb reverse tcp:3000 tcp:3000` (no manual adb, no LAN IP,
#      no router changes) so the phone reaches the PC backend through
#      the Flutter DEBUG default http://127.0.0.1:3000/api/v1
#   3. Checks backend health; starts existing backend/Docker ONLY if needed
#   4. Runs Flutter on the detected Android device (no --dart-define)
#
# Safety: NEVER resets/drops PostgreSQL data. This script never runs:
#   prisma migrate reset / db push / docker volume rm / compose down -v.
#   It only ever runs `docker compose up -d postgres` (additive) and the
#   existing START_PARABDI_WATCHDOG.ps1 / START_PARABDI_BACKEND.bat launcher.
#
# Usage:
#   .\run_parabdi.ps1                 # full setup + flutter run
#   .\run_parabdi.ps1 -NoRun          # setup only (adb + backend), skip flutter
#   Double-click Run-Parabdi.bat for the same thing.
# ============================================================================
param(
    [switch]$NoRun
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot
if (-not $ProjectRoot) { $ProjectRoot = (Get-Location).Path }
$BackendDir = Join-Path $ProjectRoot 'backend'
$WatchdogPs1 = Join-Path $ProjectRoot 'START_PARABDI_WATCHDOG.ps1'
$HealthUrl = 'http://127.0.0.1:3000/api/v1/health'
$ApiConstantsFile = Join-Path $ProjectRoot 'lib\core\constants\api_constants.dart'

function Write-Step($msg) { Write-Host ""; Write-Host "== $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "   OK  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  WARN  $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  FAIL  $msg" -ForegroundColor Red }

function Find-Adb {
    # 1. PATH
    try {
        $cmd = Get-Command adb -ErrorAction SilentlyContinue
        if ($cmd) { return $cmd.Source }
    } catch { }
    # 2. Common SDK locations
    $candidates = @()
    if ($env:ANDROID_HOME) { $candidates += (Join-Path $env:ANDROID_HOME 'platform-tools\adb.exe') }
    if ($env:ANDROID_SDK_ROOT) { $candidates += (Join-Path $env:ANDROID_SDK_ROOT 'platform-tools\adb.exe') }
    $candidates += (Join-Path $env:LOCALAPPDATA 'Android\Sdk\platform-tools\adb.exe')
    $candidates += 'C:\Android\Sdk\platform-tools\adb.exe'
    try {
        $flutterAdb = & flutter config --machine 2>$null | ConvertFrom-Json -ErrorAction SilentlyContinue
        $sdk = $flutterAdb.android_sdk_path
        if ($sdk) { $candidates += (Join-Path $sdk 'platform-tools\adb.exe') }
    } catch { }
    foreach ($c in $candidates) {
        if ($c -and (Test-Path $c)) { return $c }
    }
    return $null
}

function Get-AuthorizedDevices($Adb) {
    $out = & $Adb devices 2>&1 | Out-String
    $devices = @()
    $unauthorized = @()
    foreach ($line in ($out -split "`r?`n")) {
        $t = $line.Trim()
        if (-not $t) { continue }
        if ($t -like 'List of devices*') { continue }
        $parts = $t -split '\s+'
        if ($parts.Count -ge 2) {
            $id = $parts[0]
            $state = $parts[1]
            if ($state -eq 'device') { $devices += $id }
            elseif ($state -eq 'unauthorized') { $unauthorized += $id }
        }
    }
    return @{ Authorized = $devices; Unauthorized = $unauthorized; Raw = $out }
}

function Test-ApiHealth {
    try {
        $r = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 5
        return ($r.StatusCode -eq 200)
    } catch { return $false }
}

function Ensure-DockerEngine {
    Write-Step "Checking Docker engine"
    $up = $false
    try { cmd /c "docker info >nul 2>&1"; if ($LASTEXITCODE -eq 0) { $up = $true } } catch { }
    if (-not $up) {
        Write-Warn "Docker engine not running - starting Docker Desktop..."
        $dd = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
        if (-not (Test-Path $dd)) { $dd = "$env:LocalAppData\Programs\DockerDesktop\Docker Desktop.exe" }
        if (Test-Path $dd) {
            Start-Process $dd
            $deadline = (Get-Date).AddSeconds(120)
            while ((Get-Date) -lt $deadline) {
                Start-Sleep -Seconds 3
                try { cmd /c "docker info >nul 2>&1"; if ($LASTEXITCODE -eq 0) { $up = $true; break } } catch { }
            }
        }
        if ($up) { Write-Ok "Docker engine is up" }
        else { Write-Err "Docker engine failed to start within 120s"; exit 1 }
    } else {
        Write-Ok "Docker engine running"
    }
}

function Ensure-Postgres {
    # Additive only: never down/volume-rm/reset. Preserves pgdata volume.
    Write-Step "Ensuring PostgreSQL container (persistent volume preserved)"
    Push-Location $ProjectRoot
    try {
        cmd /c "docker compose up -d postgres >nul 2>&1"
        $deadline = (Get-Date).AddSeconds(60)
        $pgOk = $false
        while ((Get-Date) -lt $deadline) {
            $state = cmd /c "docker inspect food-app-demo-postgres-1 --format ""{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{else}}nohealth{{end}}"" 2>nul"
            if ("$state" -match 'running\|healthy') { $pgOk = $true; break }
            if ("$state" -match 'running\|nohealth') { $pgOk = $true; break }
            Start-Sleep -Seconds 2
        }
        if (-not $pgOk) { Write-Err "PostgreSQL container not healthy"; exit 1 }
        Write-Ok "PostgreSQL running + healthy (data preserved, no reset performed)"
    } finally { Pop-Location }
}

function Ensure-Backend {
    Write-Step "Checking NestJS backend on :3000"
    if (Test-ApiHealth) { Write-Ok "Backend already healthy - nothing to start"; return }
    Write-Host "   Backend not healthy - starting existing backend (only if needed)..."
    Ensure-DockerEngine
    Ensure-Postgres
    # Reuse the existing detached watchdog launcher (idempotent).
    $pidFile = Join-Path $BackendDir 'logs\watchdog.pid'
    $watchdogRunning = $false
    if (Test-Path $pidFile) {
        $wpid = Get-Content $pidFile -ErrorAction SilentlyContinue
        if ($wpid) {
            $running = Get-Process -Id ([int]$wpid) -ErrorAction SilentlyContinue
            if ($running) { $watchdogRunning = $true }
        }
    }
    if (-not $watchdogRunning) {
        if (-not (Test-Path $WatchdogPs1)) { Write-Err "watchdog not found: $WatchdogPs1"; exit 1 }
        Start-Process -FilePath 'powershell.exe' `
            -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', $WatchdogPs1) `
            -WindowStyle Hidden | Out-Null
        Write-Ok "watchdog started"
    } else {
        Write-Ok "watchdog already running"
    }
    Write-Host "   Waiting for /api/v1/health (up to 120s)..."
    $deadline = (Get-Date).AddSeconds(120)
    $healthy = $false
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 3
        if (Test-ApiHealth) { $healthy = $true; break }
    }
    if (-not $healthy) {
        Write-Err "Backend did not become healthy in 120s. See backend\logs\backend.log"
        exit 1
    }
    Write-Ok "Backend healthy on :3000"
}

# ---------------------------------------------------------------------------
# 0. Sanity: Flutter default must be loopback (permanent, IP-independent)
# ---------------------------------------------------------------------------
Write-Step "Verifying Flutter DEBUG API default"
if (Test-Path $ApiConstantsFile) {
    $src = Get-Content $ApiConstantsFile -Raw
    if ($src -match 'http://127\.0\.0\.1:3000/api/v1') {
        Write-Ok "Flutter DEBUG default is http://127.0.0.1:3000/api/v1"
    } else {
        Write-Err "api_constants.dart does not default to http://127.0.0.1:3000/api/v1"
        exit 1
    }
    if ($src -match '192\.168') {
        Write-Err "api_constants.dart still contains a hardcoded LAN IP"
        exit 1
    }
} else {
    Write-Err "missing $ApiConstantsFile"
    exit 1
}

# ---------------------------------------------------------------------------
# 1. Detect Android phone via ADB (any authorized USB device, no device ID)
# ---------------------------------------------------------------------------
Write-Step "Detecting Android device via ADB"
$Adb = Find-Adb
if (-not $Adb) {
    Write-Err "adb not found. Install Android platform-tools or set ANDROID_HOME."
    exit 1
}
Write-Ok "adb: $Adb"
try { & $Adb start-server 2>&1 | Out-Null } catch { }

$info = Get-AuthorizedDevices -Adb $Adb
$devices = @($info.Authorized)
if ($devices.Count -eq 0) {
    if (@($info.Unauthorized).Count -gt 0) {
        Write-Err "Device found but UNAUTHORIZED. Tap 'Allow USB debugging' on the phone, then re-run."
    } else {
        Write-Err "No Android device detected. Connect a phone via USB with USB debugging enabled, then re-run."
        Write-Host "   Raw `adb devices` output:"; Write-Host $info.Raw
    }
    exit 1
}
$DeviceId = $devices[0]
if ($devices.Count -gt 1) {
    Write-Warn "Multiple devices detected ($($devices -join ', ')) - using first: $DeviceId"
} else {
    Write-Ok "Android device: $DeviceId"
}

# ---------------------------------------------------------------------------
# 2. adb reverse (phone's 127.0.0.1:3000 -> PC's 3000). No LAN/router needed.
# ---------------------------------------------------------------------------
Write-Step "Setting up adb reverse tcp:3000 tcp:3000"
& $Adb -s $DeviceId reverse tcp:3000 tcp:3000
if ($LASTEXITCODE -ne 0) { Write-Err "adb reverse failed for $DeviceId"; exit 1 }
$revList = (& $Adb -s $DeviceId reverse --list 2>&1 | Out-String)
if ($revList -match 'tcp:3000') {
    Write-Ok "adb reverse active on $DeviceId (phone 127.0.0.1:3000 -> PC :3000)"
} else {
    Write-Err "adb reverse not listed after setup. Output: $revList"
    exit 1
}

# ---------------------------------------------------------------------------
# 3. Backend health; start existing backend/Docker only if needed (no reset)
# ---------------------------------------------------------------------------
Ensure-Backend

# ---------------------------------------------------------------------------
# 4. Flutter run on the detected device (no --dart-define needed)
# ---------------------------------------------------------------------------
if ($NoRun) {
    Write-Host ""
    Write-Host "==================== PARABDI READY (setup only) ====================" -ForegroundColor Green
    Write-Host " Device      : $DeviceId (adb reverse tcp:3000 active)"
    Write-Host " Backend     : $HealthUrl healthy"
    Write-Host " Flutter URL : http://127.0.0.1:3000/api/v1 (default, no --dart-define)"
    Write-Host " Next        : flutter run -d $DeviceId"
    Write-Host "=================================================================="
    exit 0
}

Write-Step "Starting Flutter on $DeviceId"
Write-Host "   Running: flutter run -d $DeviceId (debug default 127.0.0.1, no --dart-define)"
Push-Location $ProjectRoot
try {
    & flutter run -d $DeviceId
    exit $LASTEXITCODE
} finally { Pop-Location }
