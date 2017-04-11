# Directory where this file is located
$script:pwd = Split-Path $MyInvocation.MyCommand.Path

# $paths = Join-Path $pwd paths.txt
# if(Test-Path $paths) {
# 	Get-Content $paths | foreach {
# 		if(Test-Path $_) {
# 			$env:Path += ";" + $_
# 		}
# 	}
# }

$script:powershell_path = "C:\Windows\System32\WindowsPowerShell\v1.0".ToLower()
if((-Not $env:path.ToLower().contains($script:powershell_path)) -And (Test-Path $script:powershell_path)) {
  $env:path = "$env:path;$script:powershell_path"
}

$script:rsync_path = Join-Path $pwd 'rsync'
if(Test-Path $script:rsync_path) {
  $env:path = "$env:path;$script:rsync_path"
}


# $devkit = "C:\opscode\chefdk\embedded\"
# if(Test-Path $devkit) {
# 	$env:RI_DEVKIT = "$devkit"
# 	$env:path = "$devkit\bin;$devkit\mingw\bin;$env:path"
# }

$env:SSL_CERT_FILE = Join-Path $pwd cacert.pem

# set vagrant default provider
# https://www.vagrantup.com/docs/providers/default.html
$env:VAGRANT_DEFAULT_PROVIDER = "hyperv"

###########################
#
# Load all modules
#
###########################

Get-ChildItem $pwd *.psm1 | foreach {
	Import-Module $_.VersionInfo.FileName -DisableNameChecking -verbose:$false
}

try {
  $script:git_exe = @((which git.exe).Definition)[0]
  if($script:git_exe) {
    $env:GITDIR =  split-path $script:git_exe | split-path
  }
}
catch {
  Write-Error "Error setting GITDIR! " + Error[0].Exception
}

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

	if($index -lt $path.Length) {
		$userLocation = $path.Substring($index, $path.Length - $index)
	}
	
	Write-Host($userLocation) -nonewline -foregroundcolor Green 
	
	if (Test-GitRepository) {
		$branch = Get-GitBranch

		Write-Host '[' -nonewline -foregroundcolor Yellow
		Write-Host $branch -nonewline -foregroundcolor Cyan
		Write-Host ']' -nonewline -foregroundcolor Yellow
		
		$host.UI.RawUi.WindowTitle = "Git:$userLocation - $pwd"
	}
	elseif ($userLocation -eq $pwd) {
		$host.UI.RawUi.WindowTitle = "$pwd"
	}
	else {
		$host.UI.RawUi.WindowTitle = "$userLocation - $pwd"
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
if((Test-Path Function:\TabExpansion) -and !(Test-Path Function:\$defaul_tab_expansion)) {
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

# https://github.com/samneirinck/posh-docker
Import-Module posh-docker

#Check-RemoteRepository $pwd -verbose