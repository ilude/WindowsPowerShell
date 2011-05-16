
Set-Alias Get-Environment "Get-ChildItem Env:"
Set-Alias Get-Version $Host.Version


###########################
#
# Approve-Syntax
# http://rkeithhill.wordpress.com/2007/10/30/powershell-quicktip-preparsing-scripts-to-check-for-syntax-errors/
#
###########################

function Approve-Syntax {
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

function Update-Profile {
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
Set-Alias Reload-Profile Update-Profile
