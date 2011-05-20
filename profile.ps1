# Directory where this file is located
$pwd = Split-Path $MyInvocation.MyCommand.Path

$testfile = Join-Path $pwd gitutils.ps1
if(Test-Path $testfile) {
	. $testfile
}

###########################
#
# Load all modules
#
###########################

gci $pwd *.psm1 | foreach {
	$module = $_.VersionInfo.FileName;
	Import-Module $module -DisableNameChecking
	# Import-Module $module -verbose
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
	$userLocation = $path.Substring($index, $path.Length - $index)
	
	Write-Host($userLocation) -nonewline -foregroundcolor Green 
	
	if (Test-GitRepository) {
		$branch = Get-GitBranch

		Write-Host '[' -nonewline -foregroundcolor Yellow
		Write-Host $branch -nonewline -foregroundcolor Cyan
		Write-Host ']' -nonewline -foregroundcolor Yellow
		
		$host.UI.RawUi.WindowTitle = "Git:$userLocation - $pwd"
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
if(!(Test-Path Function:\$defaul_tab_expansion)) {
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

Set-Alias nano "$(Get-Editor)"
Set-Alias dev Open-EbizSolution
Set-Alias Open-EbizSolution "Invoke-Expression `"& `".\Ebiz 2007 Modules.sln`"`""
