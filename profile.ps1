# My preferred prompt for Powershell. 
# Displays git branch and stats when inside a git repository.

# See http://gist.github.com/180853 for gitutils.ps1.
$dir = Split-Path $MyInvocation.MyCommand.Path
. (Join-Path $dir gitutils.ps1)

function prompt {
	$path = ([string]$pwd)
	$index = $path.LastIndexOf('\') + 1
	$userLocation = $path.Substring($index, $path.Length - $index)
	
	$host.UI.RawUi.WindowTitle = "Git - $pwd"
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
	}
    
	Write-Host('>') -nonewline -foregroundcolor Green    
	return " "
}

function Open-EbizSolution {
	Invoke-Expression "& `".\Ebiz 2007 Modules.sln`""
}
Set-Alias dev Open-EbizSolution
Set-Alias which get-command