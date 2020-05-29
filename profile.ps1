# Directory where this file is located
$script:current_directory = Split-Path $MyInvocation.MyCommand.Path

$script:powershell_path = "C:\Windows\System32\WindowsPowerShell\v1.0".ToLower()
if ((-Not $env:path.ToLower().contains($script:powershell_path)) -And (Test-Path $script:powershell_path)) {
  $env:path = "$env:path;$script:powershell_path"
}

$script:rsync_path = Join-Path $script:current_directory 'rsync'
if (Test-Path $script:rsync_path) {
  $env:path = "$env:path;$script:rsync_path"
}

$env:SSL_CERT_FILE = Join-Path $script:current_directory cacert.pem

# set vagrant default provider
# https://www.vagrantup.com/docs/providers/default.html
$env:VAGRANT_DEFAULT_PROVIDER = "hyperv"

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

$Env:COMPOSE_CONVERT_WINDOWS_PATHS = 1

$Env:HOME = $Env:USERPROFILE

remove-item alias:cat