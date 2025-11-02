# PowerShell Profile - Requires PowerShell 3.0+
# Uses: CmdletBinding, ValidateScript attributes (PS 3.0+)
# Uses: Get-Command with -ErrorAction (PS 3.0+)
# Tested: Windows PowerShell 5.1, PowerShell Core 7.x

# Directory where this file is located
$script:current_directory = Split-Path $MyInvocation.MyCommand.Path

###########################
#
# Helper function for PATH management
#
###########################

function Add-PathIfNotExists {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$PathToAdd
  )

  $pathArray = $env:PATH.ToLower().Split(';')
  $pathToCheckLower = $PathToAdd.ToLower()

  if ($pathArray -notcontains $pathToCheckLower) {
    $env:PATH = "$PathToAdd;$env:PATH"
    Write-Verbose "Added '$PathToAdd' to PATH"
  }
  else {
    Write-Verbose "Path '$PathToAdd' already exists in PATH"
  }
}

# Add PowerShell to PATH if not present
$script:powershell_path = "C:\Windows\System32\WindowsPowerShell\v1.0".ToLower()
if (Test-Path $script:powershell_path) {
  Add-PathIfNotExists -PathToAdd $script:powershell_path
}

# Add local ./Scripts folder to PATH if present
$script:scripts_path = Join-Path $script:current_directory 'Scripts'
if (Test-Path $script:scripts_path) {
  Add-PathIfNotExists -PathToAdd $script:scripts_path
}

# Add user binary directory to PATH
Add-PathIfNotExists -PathToAdd "$env:USERPROFILE\.local\bin" 

###########################
#
# Load all modules
#
###########################

Get-ChildItem -Path $script:current_directory -Filter '*.psm1' -File | ForEach-Object {
  Import-Module $_.FullName -DisableNameChecking -Verbose:$false
}

###########################
#
# Setup prompt
#
###########################

function prompt {
  $realLASTEXITCODE = $LASTEXITCODE

  $path = $(Get-Location).Path
  $index = $path.LastIndexOf('\') + 1
  $userLocation = $path

  if ($index -lt $path.Length) {
    $userLocation = $path.Substring($index, $path.Length - $index)
  }

  Write-Host $userLocation -NoNewLine -ForegroundColor Green

  if (Test-GitRepository) {
    $branch = Get-GitBranch

    Write-Host '[' -NoNewLine -ForegroundColor Yellow
    Write-Host $branch -NoNewLine -ForegroundColor Cyan
    Write-Host ']' -NoNewLine -ForegroundColor Yellow

    $host.UI.RawUi.WindowTitle = "Git:$userLocation - $script:current_directory"
  }
  elseif ($userLocation -eq $script:current_directory) {
    $host.UI.RawUi.WindowTitle = "$script:current_directory"
  }
  else {
    $host.UI.RawUi.WindowTitle = "$userLocation - $script:current_directory"
  }

  $LASTEXITCODE = $realLASTEXITCODE
  return "> "
}

###########################
#
# Git repo sync check (startup)
#
###########################

function Show-GitRepoSyncHints {
  [CmdletBinding()]
  param(
    [string]$RepoPath = $script:current_directory,
    [switch]$SkipFetch
  )

  try {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) { return }
    if (-not (Test-Path -LiteralPath $RepoPath)) { return }

    $isRepo = & git -C "$RepoPath" rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $isRepo -ne 'true') { return }

    # Skip fetch if explicitly requested (for async mode)
    if (-not $SkipFetch) {
      # Optional fetch to update ahead/behind info; disable by setting PROFILE_GIT_FETCH=0
      $doFetch = $true
      if ($env:PROFILE_GIT_FETCH) {
        $val = $env:PROFILE_GIT_FETCH.ToLower()
        if (@('0','false','no') -contains $val) { $doFetch = $false }
      }
      if ($doFetch) {
        & git -C "$RepoPath" fetch --quiet 2>$null | Out-Null
      }
    }

    $branch   = (& git -C "$RepoPath" rev-parse --abbrev-ref HEAD 2>$null)
    $upstream = (& git -C "$RepoPath" rev-parse --abbrev-ref '@{u}' 2>$null)
    $dirty    = (& git -C "$RepoPath" status --porcelain)

    $ahead = 0; $behind = 0
    if ($upstream) {
      $counts = (& git -C "$RepoPath" rev-list --left-right --count HEAD...@{u} 2>$null)
      if ($counts) {
        $parts = $counts -split '\s+'
        if ($parts.Length -ge 2) {
          [int]$ahead  = $parts[0]
          [int]$behind = $parts[1]
        }
      }
    }

    if ($dirty -or $ahead -gt 0 -or $behind -gt 0 -or -not $upstream) {
      Write-Host "" # spacer
      Write-Host ("Repo sync status ({0}):" -f $RepoPath) -ForegroundColor Yellow
      if ($branch) { Write-Host ("  Branch: {0}" -f $branch) -ForegroundColor DarkGray }

      if ($dirty) {
        Write-Host "  - Uncommitted changes present" -ForegroundColor Red
        Write-Host ('    git -C "{0}" status' -f $RepoPath) -ForegroundColor Cyan
      }

      if (-not $upstream) {
        Write-Host ("  - No upstream set for '{0}'." -f $branch) -ForegroundColor Red
        Write-Host ('    git -C "{0}" branch --set-upstream-to origin/{1}' -f $RepoPath, $branch) -ForegroundColor Cyan
      }

      if ($behind -gt 0) {
        Write-Host ("  - Behind by {0} commit(s) - pull needed" -f $behind) -ForegroundColor Yellow
        Write-Host ('    git -C "{0}" pull' -f $RepoPath) -ForegroundColor Cyan
      }

      if ($ahead -gt 0) {
        Write-Host ("  - Ahead by {0} commit(s) - push needed" -f $ahead) -ForegroundColor Yellow
        Write-Host ('    git -C "{0}" push' -f $RepoPath) -ForegroundColor Cyan
      }

      Write-Host "" # spacer
    }
  }
  catch {
    # Be silent on startup if anything goes wrong
  }
}

function Start-AsyncGitFetch {
  [CmdletBinding()]
  param(
    [string]$RepoPath = $script:current_directory,
    [int]$TimeoutSeconds = 10
  )

  # Don't start async fetch if disabled
  $doFetch = $true
  if ($env:PROFILE_GIT_FETCH) {
    $val = $env:PROFILE_GIT_FETCH.ToLower()
    if (@('0','false','no') -contains $val) { $doFetch = $false }
  }
  if (-not $doFetch) { return }

  # Verify git and repo exist before spawning background job
  $git = Get-Command git -ErrorAction SilentlyContinue
  if (-not $git -or -not (Test-Path -LiteralPath $RepoPath)) { return }

  $isRepo = & git -C "$RepoPath" rev-parse --is-inside-work-tree 2>$null
  if ($LASTEXITCODE -ne 0 -or $isRepo -ne 'true') { return }

  # Start background job to fetch without blocking startup
  $null = Start-Job -ScriptBlock {
    param($repoPath)
    & git -C "$repoPath" fetch --quiet 2>$null
  } -ArgumentList $RepoPath -ErrorAction SilentlyContinue
}

# Run the sync hint once at startup for this profile's repo (skip fetch to run async instead)
Show-GitRepoSyncHints -SkipFetch

# Start async git fetch in background (non-blocking)
Start-AsyncGitFetch

###########################
#
# Setup Tab Expansion
#
###########################

$default_tab_expansion = 'Default_Tab_Expansion'
if ((Test-Path Function:\TabExpansion) -and !(Test-Path Function:\$default_tab_expansion)) {
  Rename-Item Function:\TabExpansion $default_tab_expansion
}

function TabExpansion($line, $lastWord) {
  $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()
  switch -regex ($lastBlock) {
    # Execute git tab completion for all git-related commands
    "$(Get-GitAliasPattern) (.*)" { GitTabExpansion $lastBlock }
    # Fall back on existing tab expansion
    default { & $default_tab_expansion $line $lastWord }
  }
}

if (Get-Module -ListAvailable -Name posh-docker) {
  # https://github.com/samneirinck/posh-docker
  Import-Module posh-docker
} 
if (Get-Module -ListAvailable -Name posh-git) {
  # https://github.com/dahlbyk/posh-git
  Import-Module posh-git
} 

# Lightweight `l` listing function (human-friendly columns + colors)
function l {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$false, ValueFromPipeline=$true)]
    [ValidateScript({Test-Path $_ -PathType Container})]
    [string]$Path = '.'
  )

  try {
    $items = Get-ChildItem -Force -Path $Path -ErrorAction Stop | Sort-Object { -not $_.PSIsContainer }, Name

    foreach ($item in $items) {
      $color = if ($item.PSIsContainer) { 'Cyan' } elseif ($item.Extension -match '\.exe|\.ps1|\.bat|\.sh') { 'Green' } else { 'Gray' }
      $mode  = $item.Mode
      # Format size so the total width (including ' KB') fits a fixed column width.
      $len   = if ($item.PSIsContainer) { '<DIR>' } else { ('{0,8}' -f ([math]::Round($item.Length / 1KB, 1))) + ' KB' }
      $date  = $item.LastWriteTime.ToString('yyyy-MM-dd HH:mm')
      # Use a 12-character width for the size column so directories and file sizes align vertically.
      Write-Host ("{0,-11} {1,12} {2,17} {3}" -f $mode, $len, $date, $item.Name) -ForegroundColor $color
    }
  }
  catch {
    Write-Error "Failed to list directory '$Path': $_"
  }
}
# The function `l` is callable directly. Avoid creating an alias with the same name (it can cause recursion).
# Create a convenient alias `ll` that maps to the `l` function instead.
Set-Alias -Name ll -Value l -Force

$Env:COMPOSE_CONVERT_WINDOWS_PATHS = 1
$Env:DOCKER_BUILDKIT=1

