# Directory where this file is located
$script:current_directory = Split-Path $MyInvocation.MyCommand.Path

$script:powershell_path = "C:\Windows\System32\WindowsPowerShell\v1.0".ToLower()
if ((-Not $env:path.ToLower().contains($script:powershell_path)) -And (Test-Path $script:powershell_path)) {
  $env:path = "$env:path;$script:powershell_path"
}

# Add local ./Scripts folder to PATH if present
$script:scripts_path = Join-Path $script:current_directory 'Scripts'
if (Test-Path $script:scripts_path) {
  $scripts_path_lc = $script:scripts_path.ToLower()
  if (-Not ($env:path.ToLower().Split(';') -contains $scripts_path_lc)) {
    $env:path = "$env:path;$script:scripts_path"
  }
}

# $script:rsync_path = Join-Path $script:current_directory 'rsync'
# if (Test-Path $script:rsync_path) {
#   $env:path = "$env:path;$script:rsync_path"
# }

# $env:SSL_CERT_FILE = Join-Path $script:current_directory cacert.pem

# # set vagrant default provider
# # https://www.vagrantup.com/docs/providers/default.html
# $env:VAGRANT_DEFAULT_PROVIDER = "hyperv"

###########################
#
# Load all modules
#
###########################

Get-ChildItem $script:current_directory *.psm1 | foreach {
  Import-Module $_.VersionInfo.FileName -DisableNameChecking -verbose:$false
}

# try {
#   $script:git_exe = @((which git.exe).Definition)[0]
#   if ($script:git_exe) {
#     $env:GITDIR = split-path $script:git_exe | split-path
#   }
# }
# catch {
#   Write-Error "Error setting GITDIR! " + Error[0].Exception
# }

###########################
#
# Setup prompt
#
###########################

function prompt {
  $realLASTEXITCODE = $LASTEXITCODE

  $path = $(get-location).Path
  $index = $path.LastIndexOf('\') + 1
  $userLocation = $path

  if ($index -lt $path.Length) {
    $userLocation = $path.Substring($index, $path.Length - $index)
  }
	
  Write-Host($userLocation) -nonewline -foregroundcolor Green 
	
  if (Test-GitRepository) {
    $branch = Get-GitBranch

    Write-Host '[' -nonewline -foregroundcolor Yellow
    Write-Host $branch -nonewline -foregroundcolor Cyan
    Write-Host ']' -nonewline -foregroundcolor Yellow
		
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
  param(
    [string]$RepoPath = $script:current_directory
  )

  try {
    $git = Get-Command git -ErrorAction SilentlyContinue
    if (-not $git) { return }
    if (-not (Test-Path -LiteralPath $RepoPath)) { return }

    $isRepo = & git -C "$RepoPath" rev-parse --is-inside-work-tree 2>$null
    if ($LASTEXITCODE -ne 0 -or $isRepo -ne 'true') { return }

    # Optional fetch to update ahead/behind info; disable by setting PROFILE_GIT_FETCH=0
    $doFetch = $true
    if ($env:PROFILE_GIT_FETCH) {
      $val = $env:PROFILE_GIT_FETCH.ToLower()
      if (@('0','false','no') -contains $val) { $doFetch = $false }
    }
    if ($doFetch) { & git -C "$RepoPath" fetch --quiet 2>$null | Out-Null }

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
        Write-Host "  • Uncommitted changes present" -ForegroundColor Red
        Write-Host ('    git -C "{0}" status' -f $RepoPath) -ForegroundColor Cyan
      }

      if (-not $upstream) {
        Write-Host ("  • No upstream set for '{0}'." -f $branch) -ForegroundColor Red
        Write-Host ('    git -C "{0}" branch --set-upstream-to origin/{1}' -f $RepoPath, $branch) -ForegroundColor Cyan
      }

      if ($behind -gt 0) {
        Write-Host ("  • Behind by {0} commit(s) — pull needed" -f $behind) -ForegroundColor Yellow
        Write-Host ('    git -C "{0}" pull' -f $RepoPath) -ForegroundColor Cyan
      }

      if ($ahead -gt 0) {
        Write-Host ("  • Ahead by {0} commit(s) — push needed" -f $ahead) -ForegroundColor Yellow
        Write-Host ('    git -C "{0}" push' -f $RepoPath) -ForegroundColor Cyan
      }

      Write-Host "" # spacer
    }
  }
  catch {
    # Be silent on startup if anything goes wrong
  }
}

# Run the sync hint once at startup for this profile's repo
Show-GitRepoSyncHints

###########################
#
# Setup Tab Expansion
#
###########################

$defaul_tab_expansion = 'Default_Tab_Expansion'
if ((Test-Path Function:\TabExpansion) -and !(Test-Path Function:\$defaul_tab_expansion)) {
  Rename-Item Function:\TabExpansion $defaul_tab_expansion
}

function TabExpansion($line, $lastWord) {
  $lastBlock = [regex]::Split($line, '[|;]')[-1].TrimStart()
  switch -regex ($lastBlock) {
    # Execute git tab completion for all git-related commands
    "$(Get-GitAliasPattern) (.*)" { GitTabExpansion $lastBlock }
    # Fall back on existing tab expansion
    default { & $defaul_tab_expansion $line $lastWord }
  }
}

if (Get-Module -ListAvailable -Name posh-docker) {
  # https://github.com/samneirinck/posh-docker
  Import-Module posh-docker
} 
if (Get-Module -ListAvailable -Name posh-git) {
  # https://github.com/samneirinck/posh-docker
  Import-Module posh-git
} 

$Env:COMPOSE_CONVERT_WINDOWS_PATHS = 1

