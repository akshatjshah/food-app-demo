# ============================================================================
# START_PARABDI_DEV.ps1 - Permanent, idempotent Parabdi stack startup
# ----------------------------------------------------------------------------
# Brings up: PostgreSQL (Docker) -> NestJS backend -> verifies API health.
# Safe to run multiple times. NEVER destroys database data.
# Never runs: prisma migrate reset / db push / drop / docker volume rm.
#
# Usage:
#   .\START_PARABDI_DEV.ps1              # normal startup (no admin needed)
#   .\START_PARABDI_DEV.ps1 -NoBackend   # infra only (PG + config)
#   .\START_PARABDI_DEV.ps1 -FixSystem   # one-time elevated fixes:
#                                         #   native PG service -> Manual
#                                         #   firewall rule for TCP 3000
#                                         #   logon scheduled task
#
# After Windows restart: run this once, or let the logon task
# "Parabdi Dev Startup" run it automatically (register via -FixSystem).
# ============================================================================
param(
    [switch]$NoBackend,
    [switch]$FixSystem
)

$ErrorActionPreference = 'Stop'
$ProjectRoot = $PSScriptRoot
if (-not $ProjectRoot) { $ProjectRoot = (Get-Location).Path }
$BackendDir  = Join-Path $ProjectRoot 'backend'
$ApiEnvFile  = Join-Path $ProjectRoot 'lib\core\constants\api_env.dart'
$BackendEnv  = Join-Path $BackendDir '.env'
$BackendLog  = Join-Path $BackendDir 'logs\backend.log'
$HealthUrl   = 'http://127.0.0.1:3000/api/v1/health'

function Write-Step($msg) { Write-Host ""; Write-Host "== $msg" -ForegroundColor Cyan }
function Write-Ok($msg)   { Write-Host "   OK  $msg" -ForegroundColor Green }
function Write-Warn($msg) { Write-Host "  WARN  $msg" -ForegroundColor Yellow }
function Write-Err($msg)  { Write-Host "  FAIL  $msg" -ForegroundColor Red }

function Test-ApiHealth {
    try {
        $r = Invoke-WebRequest -Uri $HealthUrl -UseBasicParsing -TimeoutSec 5
        return ($r.StatusCode -eq 200)
    } catch { return $false }
}

# ---------------------------------------------------------------------------
# Elevated one-time system fixes (-FixSystem)
# ---------------------------------------------------------------------------
if ($FixSystem) {
    $id = [Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()
    if (-not $id.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Err "-FixSystem requires an elevated (Administrator) PowerShell."
        Write-Host "   Right-click PowerShell - Run as administrator, then re-run with -FixSystem."
        exit 1
    }

    Write-Step "One-time system fixes"

    # 1. Native PostgreSQL service must NOT auto-start (Docker is source of truth).
    #    Its data directory C:\Program Files\PostgreSQL\15\data does not exist.
    $svc = Get-Service -Name 'postgresql-x64-15' -ErrorAction SilentlyContinue
    if ($svc) {
        if ($svc.StartType -ne 'Manual') {
            Set-Service -Name 'postgresql-x64-15' -StartupType Manual
            Write-Ok "postgresql-x64-15 startup type -> Manual (was $($svc.StartType))"
        } else {
            Write-Ok "postgresql-x64-15 already Manual"
        }
        if ($svc.Status -eq 'Running') {
            Stop-Service -Name 'postgresql-x64-15' -Force
            Write-Ok "stopped native postgresql-x64-15"
        }
    } else {
        Write-Ok "native postgresql-x64-15 service not present"
    }

    # 2. Firewall: allow inbound TCP 3000 on private/domain profiles (LAN only).
    $ruleOut = netsh advfirewall firewall show rule name="Parabdi Backend 3000" 2>&1 | Out-String
    if ($ruleOut -match 'Parabdi Backend 3000' -and $ruleOut -notmatch 'No rules match') {
        Write-Ok "firewall rule 'Parabdi Backend 3000' already exists"
    } else {
        netsh advfirewall firewall add rule name="Parabdi Backend 3000" dir=in action=allow protocol=TCP localport=3000 profile=private,domain 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Ok "firewall rule added for TCP 3000 (private/domain)" }
        else { Write-Warn "could not add firewall rule (check manually)" }
    }

    # 3. Logon scheduled task (auto-start stack after PC restart).
    try {
        $scriptPath = Join-Path $ProjectRoot 'START_PARABDI_DEV.ps1'
        $action = New-ScheduledTaskAction -Execute 'powershell.exe' `
            -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $existing = Get-ScheduledTask -TaskName 'Parabdi Dev Startup' -ErrorAction SilentlyContinue
        if (-not $existing) {
            Register-ScheduledTask -TaskName 'Parabdi Dev Startup' -Action $action -Trigger $trigger `
                -Description 'Start Parabdi PostgreSQL + backend after Windows logon (idempotent, non-destructive).' -Force | Out-Null
            Write-Ok "scheduled task 'Parabdi Dev Startup' registered (runs at logon)"
        } else {
            Set-ScheduledTask -TaskName 'Parabdi Dev Startup' -Action $action -Trigger $trigger | Out-Null
            Write-Ok "scheduled task 'Parabdi Dev Startup' refreshed"
        }
    } catch {
        Write-Warn "scheduled task registration failed: $($_.Exception.Message)"
    }

    Write-Host ""
    Write-Host "System fixes complete. Re-run without -FixSystem to start the stack." -ForegroundColor Green
    exit 0
}

# Local Android uses `adb reverse tcp:3000 tcp:3000`, so the Flutter
# DEBUG default is permanent loopback (IP-independent). This sync keeps
# api_env.dart pinned to 127.0.0.1 and never writes a LAN IP.
Write-Step "Detecting PC LAN IP"
$lanIp = $null
try {
    $route = Get-NetRoute -AddressFamily IPv4 -DestinationPrefix '0.0.0.0/0' -ErrorAction SilentlyContinue |
             Sort-Object RouteMetric | Select-Object -First 1
    if ($route) {
        $lanIp = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceIndex $route.ifIndex -ErrorAction SilentlyContinue |
                  Where-Object { $_.IPAddress -notlike '169.254.*' } |
                  Select-Object -First 1).IPAddress
    }
} catch { }

if (-not $lanIp) {
    $candidates = @(Get-NetIPAddress -AddressFamily IPv4 -ErrorAction SilentlyContinue |
        Where-Object {
            $_.IPAddress -notlike '127.*' -and
            $_.IPAddress -notlike '169.254.*' -and
            $_.IPAddress -notlike '172.*'
        })
    if ($candidates.Count -gt 0) { $lanIp = $candidates[0].IPAddress }
}
if (-not $lanIp) { $lanIp = '127.0.0.1' }
Write-Ok "LAN IP: $lanIp (Flutter uses 127.0.0.1 via adb reverse - IP-independent)"

# ---------------------------------------------------------------------------
# 2. Pin Flutter API host to loopback (adb reverse makes it IP-independent)
# ---------------------------------------------------------------------------
Write-Step "Syncing Flutter API configuration"
$desiredApiEnv = @"
// Fixed loopback host for local Android development.
// The phone reaches the PC backend via `adb reverse tcp:3000 tcp:3000`,
// so the app always uses http://127.0.0.1:3000/api/v1 (see ApiConstants).
// No LAN IP, no per-machine generated value. Kept for compatibility.
class ApiEnv {
  ApiEnv._();

  static const String host = String.fromEnvironment('API_HOST', defaultValue: '127.0.0.1');
}
"@
$currentApiEnv = if (Test-Path $ApiEnvFile) { Get-Content $ApiEnvFile -Raw } else { '' }
if ($currentApiEnv -ne $desiredApiEnv) {
    Set-Content -Path $ApiEnvFile -Value $desiredApiEnv -NoNewline -Encoding utf8
    Write-Ok "api_env.dart pinned -> host = 127.0.0.1 (adb reverse)"
} else {
    Write-Ok "api_env.dart already correct (127.0.0.1)"
}

# ---------------------------------------------------------------------------
# 3. Sync CORS entry in backend/.env (no other env keys touched)
# ---------------------------------------------------------------------------
if (Test-Path $BackendEnv) {
    $envText = Get-Content $BackendEnv -Raw
    $lanOrigin = "http://${lanIp}:3000"
    if ($envText -notlike "*$lanOrigin*") {
        if ($envText -match 'CORS_ORIGINS\s*=\s*"(.*?)"') {
            $origins = $Matches[1]
            $parts = @()
            foreach ($o in ($origins -split ',')) {
                $t = $o.Trim()
                if ($t -and $parts -notcontains $t) { $parts += $t }
            }
            $parts += $lanOrigin
            $newVal = 'CORS_ORIGINS="' + ($parts -join ',') + '"'
            $envText = [regex]::Replace($envText, 'CORS_ORIGINS\s*=\s*".*?"', $newVal)
            Set-Content -Path $BackendEnv -Value $envText -NoNewline -Encoding utf8
            Write-Ok "backend/.env CORS_ORIGINS updated"
        }
    } else {
        Write-Ok "backend/.env already contains $lanOrigin"
    }
}

# ---------------------------------------------------------------------------
# 4. Docker engine
# ---------------------------------------------------------------------------
Write-Step "Checking Docker engine"
$dockerUp = $false
try { cmd /c "docker info >nul 2>&1"; if ($LASTEXITCODE -eq 0) { $dockerUp = $true } } catch { }
if (-not $dockerUp) {
    Write-Warn "Docker engine not running - starting Docker Desktop..."
    $dd = "$env:ProgramFiles\Docker\Docker\Docker Desktop.exe"
    if (-not (Test-Path $dd)) { $dd = "$env:LocalAppData\Programs\DockerDesktop\Docker Desktop.exe" }
    if (Test-Path $dd) {
        Start-Process $dd
        $deadline = (Get-Date).AddSeconds(120)
        while ((Get-Date) -lt $deadline) {
            Start-Sleep -Seconds 3
            try { cmd /c "docker info >nul 2>&1"; if ($LASTEXITCODE -eq 0) { $dockerUp = $true; break } } catch { }
        }
    }
    if ($dockerUp) { Write-Ok "Docker engine is up" }
    else { Write-Err "Docker engine failed to start within 120s"; exit 1 }
} else {
    Write-Ok "Docker engine running"
}

# ---------------------------------------------------------------------------
# 5. PostgreSQL container (idempotent; persistent volume preserved)
# ---------------------------------------------------------------------------
Write-Step "Ensuring PostgreSQL container (persistent volume food-app-demo_pgdata)"
Push-Location $ProjectRoot
try {
    # PS 5.1: native stderr with 2>&1 becomes terminating under EAP=Stop.
    # Run via cmd so docker progress on stderr cannot kill this script.
    cmd /c "docker compose up -d postgres >nul 2>&1"
    $deadline = (Get-Date).AddSeconds(60)
    $pgOk = $false
    while ((Get-Date) -lt $deadline) {
        $state = cmd /c "docker inspect food-app-demo-postgres-1 --format ""{{.State.Status}}|{{if .State.Health}}{{.State.Health.Status}}{{else}}nohealth{{end}}"" 2>nul"
        if ("$state" -match 'running\|healthy') { $pgOk = $true; break }
        if ("$state" -match 'running\|nohealth') { $pgOk = $true; break }
        Start-Sleep -Seconds 2
    }
    if (-not $pgOk) { Write-Err "PostgreSQL container not healthy"; Pop-Location; exit 1 }
    Write-Ok "PostgreSQL running + healthy (restart=unless-stopped)"
} finally { Pop-Location }

# Read-only data sanity check
try {
    $fc = cmd /c "docker exec food-app-demo-postgres-1 psql -U postgres -d parabdi -tAc ""SELECT count(*) FROM food_items"" 2>nul"
    Write-Ok "Database reachable - food_items rows: $("$fc".Trim())"
} catch { Write-Warn "could not query food_items (container may still be starting)" }

if ($NoBackend) {
    Write-Host ""
    Write-Host "Infrastructure ready (backend skipped via -NoBackend)." -ForegroundColor Green
    exit 0
}

# ---------------------------------------------------------------------------
# 6. NestJS backend (idempotent - never starts a duplicate)
# ---------------------------------------------------------------------------
function Start-Watchdog {
    # The backend MUST outlive this script and whatever shell/IDE terminal
    # launched it. Starting `npm run start:dev` as a direct child of this
    # shell meant a Ctrl+C in any parent console killed the API, port 3000
    # went silent and the app started showing "Failed to load foods".
    # The watchdog runs in its own hidden console, starts the backend in a
    # separate console and restarts it whenever it stops being healthy -
    # including when ANOTHER project takes port 3000.
    $ps1 = Join-Path $ProjectRoot 'START_PARABDI_WATCHDOG.ps1'
    if (-not (Test-Path $ps1)) { return $false }
    $pidFile = Join-Path $BackendDir 'logs\watchdog.pid'
    if (Test-Path $pidFile) {
        $wpid = Get-Content $pidFile -ErrorAction SilentlyContinue
        if ($wpid) {
            $running = Get-Process -Id ([int]$wpid) -ErrorAction SilentlyContinue
            if ($running) { return $true }
        }
    }
    Start-Process -FilePath 'powershell.exe' `
        -ArgumentList @('-NoProfile', '-ExecutionPolicy', 'Bypass', '-WindowStyle', 'Hidden', '-File', $ps1) `
        -WindowStyle Hidden | Out-Null
    return $true
}

Write-Step "Checking NestJS backend on :3000"

if (-not (Test-Path $BackendDir)) { Write-Err "backend folder not found: $BackendDir"; exit 1 }
if (-not (Test-Path $BackendEnv)) { Write-Err "backend\.env not found"; exit 1 }
$logDir = Split-Path $BackendLog
if (-not (Test-Path $logDir)) { New-Item -ItemType Directory -Path $logDir -Force | Out-Null }

Write-Host "   Starting watchdog (auto-restart + port 3000 ownership)"
if (-not (Start-Watchdog)) {
    Write-Err "START_PARABDI_WATCHDOG.ps1 not found next to this script"
    exit 1
}
Write-Ok "watchdog running"

$healthy = Test-ApiHealth
if (-not $healthy) {
    Write-Host "   Waiting for /api/v1/health (up to 120s)..."
    $deadline = (Get-Date).AddSeconds(120)
    while ((Get-Date) -lt $deadline) {
        Start-Sleep -Seconds 3
        if (Test-ApiHealth) { $healthy = $true; break }
    }
}
if ($healthy) {
    Write-Ok "Backend healthy on :3000 (supervised - restarts automatically)"
} else {
    Write-Err "Backend did not become healthy in 120s. Last log lines:"
    if (Test-Path $BackendLog) { Get-Content $BackendLog -Tail 30 }
    exit 1
}

# ---------------------------------------------------------------------------
# 7. Representative API smoke checks (same endpoints the app screens use)
# ---------------------------------------------------------------------------
Write-Step "Smoke-testing API endpoints"
$base = 'http://127.0.0.1:3000/api/v1'
$publicEndpoints = @('/health', '/categories', '/foods', '/banners', '/subscriptions', '/delivery-slots')
$authEndpoints   = @('/addresses', '/orders', '/auth/me')
$allOk = $true

foreach ($ep in $publicEndpoints) {
    try {
        $r = Invoke-WebRequest -Uri ($base + $ep) -UseBasicParsing -TimeoutSec 10
        Write-Ok "$ep -> HTTP $($r.StatusCode)"
    } catch {
        $code = 0
        if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
        if ($code -eq 401 -or $code -eq 403) {
            Write-Ok "$ep -> HTTP $code (auth required - server reachable)"
        } else {
            Write-Err "$ep -> $($_.Exception.Message)"
            $allOk = $false
        }
    }
}

foreach ($ep in $authEndpoints) {
    try {
        $r = Invoke-WebRequest -Uri ($base + $ep) -UseBasicParsing -TimeoutSec 10
        Write-Ok "$ep -> HTTP $($r.StatusCode)"
    } catch {
        $code = 0
        if ($_.Exception.Response) { $code = [int]$_.Exception.Response.StatusCode }
        if ($code -eq 401 -or $code -eq 403) {
            Write-Ok "$ep -> HTTP $code (auth required - server reachable)"
        } else {
            Write-Err "$ep -> HTTP $code"
            $allOk = $false
        }
    }
}

# ---------------------------------------------------------------------------
# 8. LAN reachability check (what the Android device uses)
# ---------------------------------------------------------------------------
Write-Step "LAN reachability (physical Android path)"
try {
    $lan = Invoke-WebRequest -Uri "http://${lanIp}:3000/api/v1/health" -UseBasicParsing -TimeoutSec 10
    Write-Ok "http://${lanIp}:3000/api/v1/health -> HTTP $($lan.StatusCode)"
} catch {
    Write-Err "http://${lanIp}:3000 unreachable from LAN - run -FixSystem for firewall rule, or check backend bind"
    $allOk = $false
}

# ---------------------------------------------------------------------------
# 9. Register idempotent logon task if possible (non-elevated may fail)
# ---------------------------------------------------------------------------
Write-Step "Ensuring logon auto-start task"
try {
    $scriptPath = Join-Path $ProjectRoot 'START_PARABDI_DEV.ps1'
    $action = New-ScheduledTaskAction -Execute 'powershell.exe' `
        -Argument "-NoProfile -ExecutionPolicy Bypass -File `"$scriptPath`""
    $trigger = New-ScheduledTaskTrigger -AtLogOn
    $existing = Get-ScheduledTask -TaskName 'Parabdi Dev Startup' -ErrorAction SilentlyContinue
    if (-not $existing) {
        Register-ScheduledTask -TaskName 'Parabdi Dev Startup' -Action $action -Trigger $trigger `
            -Description 'Start Parabdi PostgreSQL + backend after Windows logon (idempotent, non-destructive).' -Force | Out-Null
        Write-Ok "scheduled task 'Parabdi Dev Startup' registered (runs at logon)"
    } else {
        Set-ScheduledTask -TaskName 'Parabdi Dev Startup' -Action $action -Trigger $trigger | Out-Null
        Write-Ok "scheduled task 'Parabdi Dev Startup' refreshed"
    }
} catch {
    Write-Warn "could not register scheduled task without elevation: $($_.Exception.Message)"
    Write-Warn "one-time fix: run .\START_PARABDI_DEV.ps1 -FixSystem as Administrator"
}

# ---------------------------------------------------------------------------
# Summary
# ---------------------------------------------------------------------------
Write-Host ""
Write-Host "==================== PARABDI DEV STACK READY ====================" -ForegroundColor Green
Write-Host " PostgreSQL (Docker) : healthy, volume food-app-demo_pgdata preserved"
Write-Host " Backend health      : $HealthUrl"
Write-Host " Android API URL     : http://127.0.0.1:3000/api/v1 (via adb reverse tcp:3000 tcp:3000)"
Write-Host " Flutter base URL    : lib/core/constants/api_constants.dart (default 127.0.0.1, IP-independent)"
Write-Host " Override (optional) : flutter run --dart-define=API_BASE_URL=http://127.0.0.1:3000/api/v1"
Write-Host " Backend log         : backend\logs\backend.log"
Write-Host "================================================================"
if ($allOk) {
    Write-Host " All checks passed." -ForegroundColor Green
    exit 0
} else {
    Write-Host " Some checks FAILED - see messages above." -ForegroundColor Yellow
    exit 1
}
