function Setup-Git {
	git config --global core.eol lf
  git config --global core.autocrlf input
	git config --global core.editor "'$(get-editor)' -w"
	git config --global mergetool.p4merge.trustexitcode false
	git config --global merge.tool p4merge
	git config --global diff.tool p4merge
	git config --global difftool.prompt false
	git config --global mergetool.prompt false
	git config --global mergetool.keepbackup false
  git config --global fetch.prune true
	# rebase on pull instead of merge
	git config --global branch.autosetuprebase always 
	
	# unset all aliases
	git config --get-regexp 'alias.*' | foreach-object { -split $_ | select-object -first 1  } | % { . git config --global --unset "$_" }
	
	git config --global alias.alias 'config --get-regexp \"alias.*\"'

	git config --global alias.co 'checkout'
	git config --global alias.cb 'checkout -b'
	git config --global alias.ci 'commit -m'
  git config --global alias.ca '!git add -A . && git status -s && git commit -m'
	git config --global alias.s 'status -s'
	
  	# Branching Aliases
	git config --global alias.br branch
	git config --global alias.ct '!f(){ cmd=\"git checkout -t origin/$1\"; echo $cmd; $cmd; }; f'
	git config --global alias.db '!f(){ cmd=\"git branch -D $1 && git push origin :$1\"; echo $cmd; $cmd; }; f'
	git config --global alias.dlb '!f(){ cmd=\"git branch -D $1\"; echo $cmd; $cmd; }; f'
	git config --global alias.drb '!f(){ cmd=\"git push origin :$1\"; echo $cmd; $cmd; }; f'
	git config --global alias.track '!f(){ branch=$(git name-rev --name-only HEAD); cmd=\"git branch --track $branch ${1:-origin}/${2:-$branch}\"; echo $cmd; $cmd; }; f'

	# Tagging Aliases
	# git config --global alias.dt '!powershell -ExecutionPolicy ByPass Delete-Tag'
	# git config --global alias.dlt '!powershell -ExecutionPolicy ByPass Delete-Tag -l'
	# git config --global alias.drt '!powershell -ExecutionPolicy ByPass Delete-Tag -r'
	# git config --global alias.mark '!powershell -ExecutionPolicy ByPass TagDeployment'
	git config --global alias.ts 'tag -n10'
  
	git config --global alias.unstage 'reset .'
	git config --global alias.aa "!git add -A . && git status -s"
	git config --global alias.pushall '!git push --all; git push --tags'
	git config --global alias.ls '!git --no-pager log -20 --date=short --pretty=tformat:\"%C(yellow)%h%Creset - %C(yellow)%an%Creset %C(white)%ad%Creset%C(yellow)%d%Creset %Cgreen%s%Creset\"'
	git config --global alias.ll '!git log --date=short --pretty=tformat:\"%C(yellow)%h%Creset - %C(yellow)%an%Creset %C(white)%ad%Creset%C(yellow)%d%Creset %Cgreen%s%Creset\"'
	git config --global alias.lg 'log --graph --abbrev-commit --date=relative --pretty=format:\"%C(yellow)%h%Creset - %C(yellow)%an%Creset%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset\"'
	# show files in commit
	git config --global alias.lf 'show --pretty="format:" --name-only'
	git config --global alias.wtf 'reflog'
	git config --global alias.rs 'remote show origin'

	$username = invoke-expression "git config --get user.name"
	if($username -eq "") {
		$username = "Not Set"
	}
	$username = Read-Host "Enter Fullname($username)"
	if($username) {
		git config --global user.name "'$username'"
	}

	$email = invoke-expression "git config --get user.email"
	if($email -eq "") {
		$email = "Not Set"
	}
	$email = Read-Host "Enter Email($email)"
	if($email) {
		git config --global user.email "'$email'"
	}

	if (Get-Command -CommandType Cmdlet Get-Editor -errorAction SilentlyContinue) {
		$editor = Get-Editor
		if($editor -ne $null) {
			git config --global core.editor "'$editor' -multiInst -notabbar -nosession -noPlugin"
		}
	}
}

###########################
#
# Check-RemoteRepository
# Checks if the local working head needs to be updated with a pull
#
###########################

function Check-RemoteRepository($pwd = $(pwd)) {
	pushd $pwd
	if(Test-GitRepository) {	
		if((git diff-index --name-only HEAD).length -gt 0) {
			Write-Warning "Local Powershell profile repository has uncommited changes"
		}
		
		$remote=$(git ls-remote origin HEAD | %{ ($_ -split "[\s]")[0] })
		$local=$(git rev-parse HEAD)

		Write-Verbose "Local:  $local => Remote: $remote"
		if($remote -ne $remote) {
			if(git branch --contains $remote) {
				Write-Warning "Local Powershell profile repository has changes that have not been pushed upstream"
			}
			else {
				Write-Warning "Remote Powershell profile repository has changes that are not present locally"
			}
		}
		else {
			Write-Verbose "Local Powershell profile repository is up to date"
		}
	}
	popd
}

# Git functions
# Mark Embling (http://www.markembling.info/)
# See http://gist.github.com/180853 for gitutils.ps1.

###########################
#
# Test-GitDirectory
# Is the current directory a git repository/working copy?
#
###########################

function Test-GitRepository {
		Get-GitDirectory -ne $null;
}

###########################
#
# Get-GitDirectory
#
###########################

function Get-GitDirectory {
	Get-LocalOrParentPath .git
}

###########################
#
# TrackBranches
#
###########################

function Track-Branches {
	git branch -r | `
		foreach {
			$branch = $_.Replace("origin/", "").trim();
			$count = (-split $_).Count
			if(($count -eq 1) -and ($branch -ne "HEAD") -and ($branch -ne "master")) {
				Track-Branch $branch;
			}
		}
}

###########################
#
# Track-Branch
#
###########################

function Track-Branch {
	Param(
		[string]$tagname
	)
	
	if(-not $tagname){
		$tagname = Get-GitBranch
	}
	
	git config branch.$tagname.remote origin
	git config branch.$tagname.merge refs/heads/$tagname
}

###########################
#
# Checkout-And-Track
#
###########################

function Checkout-And-Track {
  Param(
		[parameter(Mandatory=$true)]
		[string]$name
	)
  
  git checkout -t origin/$name
}

###########################
#
# TagDeployment
#
###########################

function TagDeployment {
	$date = Get-Date -format yyyy-MM-dd.HH.mm.ss
	git tag -m "Deployed $date" deploy-$date
}


###########################
#
# Delete-Tag
#
###########################

function Delete-Tag {
	Param(
    [switch]$r=$false,
    [switch]$l=$false,
		[parameter(Mandatory=$true)]
		[string]$name
	)
  
  if($r -and -not $l) {
    git push --delete origin $name
  }
  elseif($l -and -not $r) {
    git tag -d $name
  }
  else {
		git push --delete origin $name
    git tag -d $name
  }
}

###########################
#
# Test-Tag
#
###########################

function Test-Tag {
  Param(
		[switch]$r=$false,
		[parameter(Mandatory=$true)]
		[string]$name
	)
	
	if($r) {
		return (git show-ref --tags | Where-Object { $_.Trim() -eq "origin/$name" } | Measure-Object).Count -eq 1
	}
	else {
		return (git tag | Where-Object { $_.Trim() -eq "$name" } | Measure-Object).Count -eq 1
	}
}


###########################
#
# Delete-Branch
#
###########################

function Delete-Branch {
	Param(
		[switch]$D=$false,
		[switch]$r=$false,
    [switch]$l=$false,
		[parameter(Mandatory=$true)]
		[string]$name
	)
  
  $force = "-d"
  if($D) {
    $force = "-D"
  }
	
	if($r -and -not $l) {
    if(Test-Branch -r $name) {
      git push origin :$name
    }
		else {
      Write-Warning "Branch $name does not exist in the remote repository!"
    }
	}
  elseif($l -and -not $r) {
    if((Test-Branch $name)) {
			git branch $force $name
		}
    else {
      Write-Warning "Branch $name does not exist in the local repository!"
    }
  }
	else {
		if((Test-Branch -r $name)) {
			git push origin :$name
		}
    else {
      Write-Warning "Branch $name does not exist in the remote repository!"
    }
		
		if((Test-Branch $name)) {
			git branch $force $name
		}
    else {
      Write-Warning "Branch $name does not exist in the local repository!"
    }
	}
}

###########################
#
# Test-Branch
#
###########################

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

###########################
#
# Enable-GitColors
#
###########################

function Enable-GitColors {
	$env:TERM = 'cygwin'
}

###########################
#
# Get-GitAliasPattern
#
###########################

function Get-GitAliasPattern {
	$aliases = @('git') + (Get-Alias | where {$_.definition -eq 'git' } | select -Exp Name) -join '|' 
	"(" + $aliases + ")"
}

###########################
#
# Get-GitBranch
#
###########################

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

			dbg 'Falling back on parsing HEAD' $sw
			$ref = Get-Content $gitDir\HEAD 2>$null
			dbg "Head => $ref"
			if ($ref -match 'ref: (?<ref>.+)') {
				$b = $Matches['ref']
			} elseif ($ref -and $ref.Length -ge 7) {
				$b = $ref.Substring(0,7)+'...'
			} else {
				$b = 'unknown'
			}
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

function Get-GitAliases {
  $aliases = (git config --get-regexp 'alias.*' | foreach-object { 
    $array = -split ($_ -replace 'alias\.'); 
    $output = New-Object PsObject; 
    Add-Member -InputObject $output NoteProperty Alias ($array[0]); 
    Add-Member -InputObject $output NoteProperty Command ([string]::join(" ", $array[1..($array.length-1)])); return $output  
  })
  
  return $aliases
}

function Display-GitAliases {
  Get-GitAliases | ft -autosize
}


Export-ModuleMember Setup-Git, Check-RemoteRepository, Test-GitRepository, Track-Branch, Track-Branches, Checkout-And-Track, TagDeployment, Delete-Tag, Test-Tag, Delete-RemoteTag, Delete-Branch, Test-Branch, Enable-GitColors, Get-GitAliasPattern, Get-GitBranch, Display-GitAliases
