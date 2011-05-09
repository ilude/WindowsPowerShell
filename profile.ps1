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
	Import-Module $module
}

###########################
#
# Setup prompt
#
###########################

function prompt {
	$path = ([string]$pwd)
	$index = $path.LastIndexOf('\') + 1
	$userLocation = $path.Substring($index, $path.Length - $index)
	
	
	Write-Host($userLocation) -nonewline -foregroundcolor Green 
	
	if (isCurrentDirectoryGitRepository) {
		$branch = GitBranchName

		Write-Host('[') -nonewline -foregroundcolor Yellow
		if($branch -eq "merging") {
			Write-Host("merging") -nonewline -foregroundcolor Red
		}
		else {
			Write-Host($branch) -nonewline -foregroundcolor Cyan
		}
		Write-Host(']') -nonewline -foregroundcolor Yellow
		
		$host.UI.RawUi.WindowTitle = "Git:$userLocation - $pwd"
	}
	else {
		$host.UI.RawUi.WindowTitle = "$userLocation - $pwd"
	}
    
	Write-Host('>') -nonewline -foregroundcolor Green    
	return " "
}

###########################
#
# Reload Profile
#
###########################

function Reload-Profile {
    @(
        $Profile.AllUsersAllHosts,
        $Profile.AllUsersCurrentHost,
        $Profile.CurrentUserAllHosts,
        $Profile.CurrentUserCurrentHost
    ) | % {
        if(Test-Path $_){
            Write-Verbose "Running $_"
            . $_
        }
    }    
}

Set-Alias dev Open-EbizSolution
Set-Alias which get-command
Set-Alias Open-EbizSolution "Invoke-Expression `"& `".\Ebiz 2007 Modules.sln`"`""
