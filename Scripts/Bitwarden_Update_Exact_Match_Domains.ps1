<#
.SYNOPSIS
  Enforce Exact (match=1) URL matching for specified domains across your Bitwarden/Vaultwarden vault.

.DESCRIPTION
  - Reads domains from a text file named "Bitwarden_Exact_Match_Domains.txt" (one domain per line).
    - If the file does not exist, the script creates it with the header comment:
      "# add domains one per line to this file" and exits so you can populate it.
    - Default location: next to this script. You can override with -DomainsFile.
  - Blank lines and comments starting with '#' (at line start or inline) are ignored.
  - Optionally merges additional domains passed via -Domains.
  - Prompts once for your master password (secure), logs in if needed, unlocks, and sets BW_SESSION for this run.
  - Syncs before and after changes.
  - Sets .login.uris[].match = 1 for any URI whose hostname equals any listed domain or ends with ".<domain>" (subdomains included).
  - Reports updated and failed items (e.g., org read-only). Leaves BW_SESSION set for reuse.

.PARAMETER Domains
  Additional domains to enforce, merged with the contents of the domains file.

.PARAMETER DomainsFile
  Optional path to the domains file. One domain per line; lines beginning with '#' are treated as comments.

.PARAMETER User
  Optional. Login identifier (typically your Bitwarden email). Used if login is needed and you're not already authenticated.

.EXAMPLE
  .\Bitwarden_Update_Exact_Match_Domains.ps1
.EXAMPLE
  .\Bitwarden_Update_Exact_Match_Domains.ps1 -User you@example.com
.EXAMPLE
  .\Bitwarden_Update_Exact_Match_Domains.ps1 -Domains "example.com","corp.example.org"
.EXAMPLE
  .\Bitwarden_Update_Exact_Match_Domains.ps1 -DomainsFile "D:\lists\bw-exact.txt"

.NOTES
  Requires: Bitwarden CLI (bw) and jq (1.6+) available in PATH.
#>

param(
  [string[]]$Domains = @(),
  [string]$User,
  [string]$DomainsFile
)

$ErrorActionPreference = "Stop"

function Get-PlainText {
  param([System.Security.SecureString]$Secure)
  $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
  try { [Runtime.InteropServices.Marshal]::PtrToStringUni($bstr) }
  finally { if ($bstr -ne [IntPtr]::Zero) { [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($bstr) } }
}

function Require-Tool {
  param([string]$Name)
  if (-not (Get-Command $Name -ErrorAction SilentlyContinue)) {
    throw "Required tool not found in PATH: $Name"
  }
}

try {
  Require-Tool bw
  Require-Tool jq

  # Resolve domains to enforce: from file (preferred) and/or -Domains parameter
  if (-not $DomainsFile -or [string]::IsNullOrWhiteSpace($DomainsFile)) {
    $scriptDir = $PSScriptRoot
    if ([string]::IsNullOrWhiteSpace($scriptDir)) {
      $scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
    }
    if ([string]::IsNullOrWhiteSpace($scriptDir)) {
      $scriptDir = (Get-Location).Path
    }
    $DomainsFile = Join-Path $scriptDir 'Bitwarden_Exact_Match_Domains.txt'
  }

  if (-not (Test-Path $DomainsFile)) {
    # Create the domains file with a header comment
    New-Item -ItemType File -Path $DomainsFile -Force | Out-Null
    Set-Content -Path $DomainsFile -Value "# add domains one per line to this file`r`n"
    Write-Host ("Created domain list file at: {0}" -f $DomainsFile) -ForegroundColor Yellow
    Write-Host "Please add domains (one per line) to the file and re-run this script." -ForegroundColor Yellow
    return
  }

  $fileDomains = Get-Content -Path $DomainsFile -ErrorAction SilentlyContinue |
    ForEach-Object {
      $t = $_.Trim()
      if (-not $t) { return }
      # Remove full-line comments and inline comments beginning with '#'
      if ($t.StartsWith('#')) { return }
      ($t -split '#', 2)[0].Trim()
    } |
    Where-Object { $_ }

  if ($Domains -and $Domains.Count -gt 0) {
    $DomainsEffective = @($Domains + $fileDomains) | ForEach-Object { $_.ToLower() } | Sort-Object -Unique
  } else {
    $DomainsEffective = @($fileDomains | ForEach-Object { $_.ToLower() } | Sort-Object -Unique)
  }

  if (-not $DomainsEffective -or $DomainsEffective.Count -eq 0) {
    Write-Host ("No domains found in file: {0}" -f $DomainsFile) -ForegroundColor Yellow
    Write-Host "Add domains (one per line) to the file and re-run." -ForegroundColor Yellow
    return
  }

  Write-Host ("Loaded {0} domains from {1}" -f $DomainsEffective.Count, $DomainsFile) -ForegroundColor Cyan

  Write-Host "Bitwarden: preparing session (login/unlock)..." -ForegroundColor Cyan

  # Check status first, then collect credentials only as needed
  $statusRaw = bw status | Out-String
  $status = $null
  try { $status = $statusRaw | ConvertFrom-Json } catch { }

  $state = "unknown"
  if ($status -and ($status.PSObject.Properties.Name -contains 'status') -and $status.status) {
    $state = $status.status
  }

  switch ($state) {
    'unauthenticated' {
      if (-not $User) {
        $User = Read-Host "Enter Bitwarden login (email)"
      }
      # Prompt for master password once
      $secure = Read-Host "Enter Bitwarden master password for $User" -AsSecureString
      if (-not $secure) { throw "No password provided." }
      $plain = Get-PlainText -Secure $secure
      if (-not $plain) { throw "Failed to read password." }
      $env:BW_PASSWORD = $plain

      Write-Host "Logging in as $User..." -ForegroundColor Yellow
      bw login $User --passwordenv BW_PASSWORD | Out-Null

      Write-Host "Unlocking vault..." -ForegroundColor Yellow
      $session = bw unlock --raw --passwordenv BW_PASSWORD
      if (-not $session) { throw "Unlock failed (no session token returned)." }
      $env:BW_SESSION = $session

      # Clear password env
      Remove-Item Env:BW_PASSWORD -ErrorAction SilentlyContinue
      $plain = $null
      $secure = $null
    }
    'locked' {
      # Prompt for master password to unlock
      $secure = Read-Host "Enter Bitwarden master password" -AsSecureString
      if (-not $secure) { throw "No password provided." }
      $plain = Get-PlainText -Secure $secure
      if (-not $plain) { throw "Failed to read password." }
      $env:BW_PASSWORD = $plain

      Write-Host "Unlocking vault..." -ForegroundColor Yellow
      $session = bw unlock --raw --passwordenv BW_PASSWORD
      if (-not $session) { throw "Unlock failed (no session token returned)." }
      $env:BW_SESSION = $session

      # Clear password env
      Remove-Item Env:BW_PASSWORD -ErrorAction SilentlyContinue
      $plain = $null
      $secure = $null
    }
    'unlocked' {
      Write-Host "Vault already unlocked." -ForegroundColor Green
      # If a session is already set in environment, keep using it. Otherwise, we will rely on current unlocked state
      # Note: commands below use --session; if BW_SESSION is absent, set one by unlocking with password when convenient
      if (-not $env:BW_SESSION) {
        # As a lightweight approach, proceed and let commands fallback to unlocked state if supported.
        # If any command requires a session explicitly, you can run: $env:BW_SESSION = (bw unlock --raw)
      }
    }
    Default {
      # Unknown state: attempt unlock path
      $secure = Read-Host "Enter Bitwarden master password" -AsSecureString
      if (-not $secure) { throw "No password provided." }
      $plain = Get-PlainText -Secure $secure
      if (-not $plain) { throw "Failed to read password." }
      $env:BW_PASSWORD = $plain
      $session = bw unlock --raw --passwordenv BW_PASSWORD
      if (-not $session) { throw "Unlock failed (no session token returned)." }
      $env:BW_SESSION = $session
      Remove-Item Env:BW_PASSWORD -ErrorAction SilentlyContinue
      $plain = $null
      $secure = $null
    }
  }

  # Initial sync
  Write-Host "Syncing..." -ForegroundColor Yellow
  $sessionArgs = @()
  if ($env:BW_SESSION) {
    $sessionArgs = @('--session', $env:BW_SESSION)
    Write-Host "Using session token for CLI calls." -ForegroundColor DarkGray
  } else {
    Write-Host "No BW_SESSION; using unlocked state (no --session)." -ForegroundColor DarkGray
  }
  bw sync @sessionArgs | Out-Null

  # Prepare jq programs and data
  $domainJson = $DomainsEffective | ConvertTo-Json -Compress

  $jqIDs = @'
def tostr($x): if $x == null then "" else ($x|tostring) end;
def host_of($s):
  (tostr($s)) as $u
  | (try ($u | capture("^(?:(?<scheme>[A-Za-z][A-Za-z0-9+.-]*):\\/\\/)?(?:(?<userinfo>[^@\\/]+)@)?(?<host>[^:\\/\\?#]+)")) .host catch $u);

def matches_domains($u; $domains):
  (host_of($u) | ascii_downcase) as $h
  | any($domains[]; . as $d | ($h == $d) or ($h | endswith("." + $d)));

[ .[]
  | select(.login?.uris? != null)
  | select([.login.uris[]? | matches_domains(.uri; $DOMAINS)] | any)
  | .id
] | unique[]
'@

  $jqUpdate = @'
def tostr($x): if $x == null then "" else ($x|tostring) end;
def host_of($s):
  (tostr($s)) as $u
  | (try ($u | capture("^(?:(?<scheme>[A-Za-z][A-Za-z0-9+.-]*):\\/\\/)?(?:(?<userinfo>[^@\\/]+)@)?(?<host>[^:\\/\\?#]+)")) .host catch $u);

def matches_domains($u; $domains):
  (host_of($u) | ascii_downcase) as $h
  | any($domains[]; . as $d | ($h == $d) or ($h | endswith("." + $d)));

(.login.uris[]? | select(matches_domains(.uri; $DOMAINS)) | .match) = 1
'@

  # Collect IDs to update
  Write-Host "Scanning for matching items..." -ForegroundColor Cyan
  $ids = bw list items @sessionArgs `
    | jq -r --argjson DOMAINS $domainJson $jqIDs

  $idCount = ($ids | Measure-Object).Count
  Write-Host ("Found {0} items matching target domains." -f $idCount) -ForegroundColor Cyan

  if (-not $ids) {
    Write-Host "No items found matching the given domains." -ForegroundColor Yellow
    return
  }

  $updated = New-Object System.Collections.Generic.List[string]
  $failed  = New-Object System.Collections.Generic.List[string]

  foreach ($id in $ids) {
  $json = bw get item $id @sessionArgs
    if (-not $json) { $failed.Add("$id`tget failed"); continue }

    $new = $json | jq --argjson DOMAINS $domainJson $jqUpdate
    if (-not $new) { $failed.Add("$id`tjq update failed"); continue }

  $res = ($new | bw encode | bw edit item $id @sessionArgs 2>&1)
    if ($LASTEXITCODE -eq 0) {
      $updated.Add($id)
    } else {
      $failed.Add("$id`t$res")
    }
  }

  # Final sync if we changed anything
  if ($updated.Count -gt 0) {
    Write-Host "Re-syncing after updates..." -ForegroundColor Yellow
  bw sync @sessionArgs | Out-Null
  }

  # Summary
  Write-Host ""
  Write-Host ("Updated items: {0}" -f $updated.Count) -ForegroundColor Green
  if ($updated.Count -gt 0) {
    $updated -join "`n" | ForEach-Object { Write-Host "  $_" }
  }
  if ($failed.Count -gt 0) {
    Write-Host ("Failed items: {0}" -f $failed.Count) -ForegroundColor Red
    $failed | ForEach-Object { Write-Host "  $_" }
  } else {
    Write-Host "No failures reported." -ForegroundColor Green
  }

} catch {
  Write-Error $_
} finally {
  # Do not clear BW_SESSION so the session remains usable after the script
  # Remove-Item Env:BW_SESSION -ErrorAction SilentlyContinue
  Remove-Item Env:BW_PASSWORD -ErrorAction SilentlyContinue
}