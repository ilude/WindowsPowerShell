# Git functions
# Mark Embling (http://www.markembling.info/)
# See http://gist.github.com/180853 for gitutils.ps1.

# Is the current directory a git repository/working copy?
function Test-GitRepository {
		Get-GitDirectory -ne $null;
}

function Get-GitDirectory {
	Get-LocalOrParentPath .git
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

function Enable-GitColors {
	$env:TERM = 'cygwin'
}

function Get-GitAliasPattern {
	$aliases = @('git') + (Get-Alias | where {$_.definition -eq 'git' } | select -Exp Name) -join '|' 
	"(" + $aliases + ")"
}


function Get-GitBranch($gitDir = $(Get-GitDirectory), [Diagnostics.Stopwatch]$sw) {
	if ($gitDir) {
		dbg 'Finding branch' $sw
		dbg "$gitDir"
		$r = ''; $b = ''; $c = ''
		if (Test-Path $gitDir\rebase-merge\interactive) {
			dbg 'Found rebase-merge\interactive' $sw
			$r = '|REBASE-i'
			$b = "$(Get-Content $gitDir\rebase-merge\head-name)"
		} elseif (Test-Path $gitDir\rebase-merge) {
			dbg 'Found rebase-merge' $sw
			$r = '|REBASE-m'
			$b = "$(Get-Content $gitDir\rebase-merge\head-name)"
		} else {
			if (Test-Path $gitDir\rebase-apply) {
				dbg 'Found rebase-apply' $sw
				if (Test-Path $gitDir\rebase-apply\rebasing) {
					dbg 'Found rebase-apply\rebasing' $sw
					$r = '|REBASE'
				} elseif (Test-Path $gitDir\rebase-apply\applying) {
					dbg 'Found rebase-apply\applying' $sw
					$r = '|AM'
				} else {
					dbg 'Found rebase-apply' $sw
					$r = '|AM/REBASE'
				}
			} elseif (Test-Path $gitDir\MERGE_HEAD) {
				dbg 'Found MERGE_HEAD' $sw
				$r = '|MERGING'
			} elseif (Test-Path $gitDir\BISECT_LOG) {
				dbg 'Found BISECT_LOG' $sw
				$r = '|BISECTING'
			}

			$b = '{0}' -f (
				Coalesce-Args `
					{ dbg 'Trying describe' $sw; git describe --exact-match HEAD 2>$null } `
					{
						dbg 'Falling back on parsing HEAD' $sw
						$ref = Get-Content $gitDir\HEAD 2>$null
						dbg "Head => $ref"
						if ($ref -match 'ref: (?<ref>.+)') {
							return $Matches['ref']
						} elseif ($ref -and $ref.Length -ge 7) {
							return $ref.Substring(0,7)+'...'
						} else {
							return 'unknown'
						}
					}
				)
		}

		if ('true' -eq $(git rev-parse --is-inside-git-dir 2>$null)) {
			dbg 'Inside git directory' $sw
			if ('true' -eq $(git rev-parse --is-bare-repository 2>$null)) {
				$c = 'BARE:'
			} else {
				$b = 'GIT_DIR!'
			}
		}

		"$c$($b -replace 'refs/heads/','')$r"
	}
}

