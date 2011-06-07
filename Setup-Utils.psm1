
###########################
#
# Get-Editor
#
###########################

function Get-Editor {
	$path = Resolve-Path ("$env:ProgramFiles*" + "\notepad*\notepad*");
	if(Test-Path $path) {
		return $path.Path;
	}
	
	$path = Join-Path $env:windir "\system32\notepad.exe"
	if(Test-Path $path) {
		return $path;
	}
	
	return $null;
}

###########################
#
# Approve-Syntax
# http://rkeithhill.wordpress.com/2007/10/30/powershell-quicktip-preparsing-scripts-to-check-for-syntax-errors/
#
###########################

function Test-Syntax {
	param($path, [switch]$verbose)

	if ($verbose) {
		$VerbosePreference = ‘Continue’
	}

	trap { Write-Warning $_; $false; continue }
	& `
	{
		$contents = get-content $path
		$contents = [string]::Join([Environment]::NewLine, $contents)
		[void]$ExecutionContext.InvokeCommand.NewScriptBlock($contents)
		Write-Verbose "Parsed without errors"
		$true
	}
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
	) | foreach {
		if(Test-Path $_){
			Write-Verbose "Running $_"
			. $_
		}
	}    
}

# General Utility Functions
# https://github.com/dahlbyk/posh-git/blob/master/Utils.ps1

###########################
#
# Coalesce-Args
#
###########################

function Coalesce-Args {
    $result = $null
    foreach($arg in $args) {
        if ($arg -is [ScriptBlock]) {
            $result = & $arg
        } else {
            $result = $arg
        }
        if ($result) { break }
    }
    $result
}

Set-Alias ?? Coalesce-Args -Force

###########################
#
# Get-LocalOrParentPath
#
###########################

function Get-LocalOrParentPath($path) {
    $checkIn = Get-Item .
    while ($checkIn -ne $NULL) {
        $pathToTest = [System.IO.Path]::Combine($checkIn.fullname, $path)
        if (Test-Path $pathToTest) {
            return $pathToTest
        } else {
            $checkIn = $checkIn.parent
        }
    }
    return $null
}

###########################
#
# Debug
#
###########################

function Debug($Message, [Diagnostics.Stopwatch]$Stopwatch) {
    if($Stopwatch) {
        Write-Verbose ('{0:00000}:{1}' -f $Stopwatch.ElapsedMilliseconds,$Message) -Verbose # -ForegroundColor Yellow
    }
		# Write-Warning $Message
}

Set-Alias dbg Debug

###########################
#
# Get-ScriptDirectory
#
###########################

function Get-ScriptDirectory
{
	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}

function Get-Environment {
	Get-ChildItem Env:
}

function Open-EbizSolution {
	Invoke-Expression "& '.\Ebiz 2007 Modules.sln'"
}

Set-Alias dev Open-EbizSolution
Set-Alias Get-Env Get-Environment
Set-Alias Get-Version $Host.Version
Set-Alias nano "$(Get-Editor)"

Export-ModuleMember `
	Get-Editor, Test-Syntax, Reload-Profile, Coalesce-Args, Get-LocalOrParentPath, Debug, Get-ScriptDirectory, Get-Environment, Open-EbizSolution `
	-Alias ??, dbg, dev, Get-Env, Get-Version, nano