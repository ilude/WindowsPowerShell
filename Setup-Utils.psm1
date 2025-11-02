
###########################
#
# Get-Editor
#
###########################

function Get-Editor {
	# Try to find VS Code
	$vscodeExe = Get-Command code.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source | Select-Object -First 1
	if ($vscodeExe) {
		return $vscodeExe
	}

	# Try Program Files locations
	$editorPaths = @(
		(Join-Path $env:PROGRAMFILES 'Microsoft VS Code\code.exe'),
		(Join-Path $env:PROGRAMFILES 'Microsoft VS Code\bin\code.exe'),
		(Join-Path $env:PROGRAMFILES 'Notepad++\notepad++.exe'),
		(Join-Path $env:WINDIR 'System32\notepad.exe')
	)

	foreach ($editorPath in $editorPaths) {
		if (Test-Path $editorPath) {
			return $editorPath
		}
	}

	return $null
}

###########################
#
# Test-Syntax
# http://rkeithhill.wordpress.com/2007/10/30/powershell-quicktip-preparsing-scripts-to-check-for-syntax-errors/
#
###########################

function Test-Syntax {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[ValidateScript({Test-Path $_ -PathType Leaf})]
		[string]$Path,

		[switch]$Verbose
	)

	if ($Verbose) {
		$VerbosePreference = 'Continue'
	}

	trap { Write-Warning $_; $false; continue }
	& `
	{
		$contents = Get-Content $Path
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
	[CmdletBinding()]
	param()

	@(
		$Profile.AllUsersAllHosts,
		$Profile.AllUsersCurrentHost,
		$Profile.CurrentUserAllHosts,
		$Profile.CurrentUserCurrentHost
	) | ForEach-Object {
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
	[CmdletBinding()]
	param(
		[Parameter(ValueFromRemainingArguments=$true)]
		[object[]]$Arguments
	)

	$result = $null
	foreach($arg in $Arguments) {
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

function Get-LocalOrParentPath {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[string]$Path
	)

	$checkIn = Get-Item .
	while ($checkIn -ne $NULL) {
		$pathToTest = [System.IO.Path]::Combine($checkIn.fullname, $Path)
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

function Debug {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[string]$Message,

		[Diagnostics.Stopwatch]$Stopwatch
	)

	if($Stopwatch) {
		Write-Verbose ('{0:00000}:{1}' -f $Stopwatch.ElapsedMilliseconds,$Message) -Verbose
	}
}

Set-Alias dbg Debug

###########################
#
# Get-ScriptDirectory
#
###########################

function Get-ScriptDirectory {
	[CmdletBinding()]
	param()

	$Invocation = (Get-Variable MyInvocation -Scope 1).Value
	Split-Path $Invocation.MyCommand.Path
}

###########################
#
# ConvertTo-PlainText
#
###########################

function ConvertTo-PlainText {
	[CmdletBinding()]
	param(
		[Parameter(Mandatory=$true)]
		[Security.SecureString]$SecureString
	)

	$marshal = [Runtime.InteropServices.Marshal]
	$ptr = $marshal::SecureStringToBSTR($SecureString)
	$result = $marshal::PtrToStringAuto($ptr)
	$marshal::ZeroFreeBSTR($ptr)
	return $result
}

function Get-Environment {
	[CmdletBinding()]
	param()

	Get-ChildItem Env:
}

function Create-Console {
	[CmdletBinding()]
	param(
		[string]$Path = $(pwd)
	)

	$console = Get-Command ConEmu64.exe -ErrorAction SilentlyContinue | Select-Object -ExpandProperty Source | Select-Object -First 1
	if (-not $console) {
		Write-Error "ConEmu is not installed or not in PATH"
		return
	}

	& $console /config "shell" /dir "$Path" /cmd powershell -cur_console:n
}

Set-Alias sh Create-Console
Set-Alias Get-Env Get-Environment
Set-Alias nano "$(Get-Editor)"

Export-ModuleMember -Function * -Alias *
