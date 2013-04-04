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

###########################
#
# Load all modules
#
###########################

Get-ChildItem $pwd *.psm1 | foreach {
	Import-Module $_.VersionInfo.FileName -DisableNameChecking -verbose:$false
}

try {
  $env:GITDIR = (which git.cmd).Definition | split-path | split-path
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

	$path = ([string]$pwd)
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

Check-RemoteRepository $pwd -verbose
