# Git functions
# Mark Embling (http://www.markembling.info/)
# See http://gist.github.com/180853 for gitutils.ps1.

# Is the current directory a git repository/working copy?
function isCurrentDirectoryGitRepository {
	try {
    if ((Test-Path ".git") -eq $TRUE) {
			return $TRUE
    }
    
    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
			$pathToTest = $checkIn.fullname + '/.git'
			if ((Test-Path $pathToTest) -eq $TRUE) {
				return $TRUE
			} else {
				$checkIn = $checkIn.parent
			}
    }
		return $FALSE
	}	
	catch {
		return $FALSE
	}
}

function TrackBranches {
	git branch -r | `
		Select-Object @{Expression = {$_.Trim().Replace("origin/", "")}} | ` # trim whitespace and strip leading origin
		Where-Object { ($_.Trim().StartsWith("origin/")) -and ($_.Trim() -ne "origin/HEAD") -and ($_.Trim() -ne "origin/master") } | `
		foreach {
			TrackBranch $branch;
		}
}

function TrackBranch {
	Param(
		[string]$tagname
	)
	
	if(! $tagname){
		$tagname = GitBranchName
	}
	
	git config branch.$tagname.remote origin
	git config branch.$tagname.merge refs/heads/$tagname
}

function TagDeployment {
	$date = Get-Date -format yyyy-MM-dd.HH.mm.ss
	git tag -m "Deployed $date" deploy-$date
}

function Remove-Tag {
	Param(
		[parameter(Mandatory=$true)]
		[string]$name
	)
	
	git tag -d $name
	if($?) {
		git push origin :refs/tags/$name
	}
}

function Remove-Branch {
	Param(
		[switch]$D=$false,
		[switch]$r=$false,
		[parameter(Mandatory=$true)]
		[string]$name
	)
	
	if(($r) -and (Test-Branch -r $name)) {
		git push origin :$name
	}
	else {
		$force = "-d"
		if($D) {
			$force = "-D"
		}
		
		git branch $force $name
		
		if($? -and (Test-Branch -r $name)) {
			git push origin :$name
		}
	}
}

function Test-Branch {
	Param(
		[switch]$r=$false,
		[parameter(Mandatory=$true)]
		[string]$name
	)
	
	if($r) {
		return (git branch -r | Where-Object { $_.Trim() -eq "origin/$name" } | Measure-Object).Count -eq 1
	}
	else {
		return (git branch | Where-Object { $_.Trim() -eq "$name" } | Measure-Object).Count -eq 1
	}
}

# Get the current branch
function GitBranchName {
	try {
		$currentBranch = git symbolic-ref HEAD
		$index = $currentBranch.LastIndexOf('/') + 1
		if($index -gt 0) {
			return $currentBranch.Substring($index, $currentBranch.Length - $index)
		}
		return "merging"
	}
	catch {
		return ""
	}
}

# Extracts status details about the repo
function gitStatus {
    $untracked = $FALSE
    $added = 0
    $modified = 0
    $deleted = 0
    $ahead = $FALSE
    $aheadCount = 0
    
    $output = git status
    
    $branchbits = $output[0].Split(' ')
    $branch = $branchbits[$branchbits.length - 1]
    
    $output | foreach {
        if ($_ -match "^\#.*origin/.*' by (\d+) commit.*") {
            $aheadCount = $matches[1]
            $ahead = $TRUE
        }
        elseif ($_ -match "deleted:") {
            $deleted += 1
        }
        elseif (($_ -match "modified:") -or ($_ -match "renamed:")) {
            $modified += 1
        }
        elseif ($_ -match "new file:") {
            $added += 1
        }
        elseif ($_ -match "Untracked files:") {
            $untracked = $TRUE
        }
    }
    
    return @{"untracked" = $untracked;
             "added" = $added;
             "modified" = $modified;
             "deleted" = $deleted;
             "ahead" = $ahead;
             "aheadCount" = $aheadCount;
             "branch" = $branch}
}
