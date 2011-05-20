###########################
#
# Reload-Module
#
###########################

function Reload-Module($ModuleName) {
	if((get-module -all | where{$_.name -eq "$ModuleName"} | measure-object).count -gt 0) {
		
		remove-module $ModuleName
		Write-Verbose "Module $ModuleName Unloaded"
		
		$pwd = Get-ScriptDirectory
		if(Test-Path (join-Path $pwd "$ModuleName.psm1")) {
			Write-Host (join-Path $pwd "$ModuleName.psm1")
			$ModuleName = (join-Path $pwd "$ModuleName.psm1")
		}
		
		import-module $ModuleName
		Write-Verbose "Module $ModuleName Loaded"
	}
	else {
		Write-Warning "Module $ModuleName Doesn't Exist"
	}
}

###########################
#
# Initialize-Modules
#
###########################

function Initialize-Modules {
	Get-Module | Where-Object { Test-Method $_.Name $_.Name } | foreach {
		$functionName =  $_.Name
		Write-Verbose "Initializing Module $functionName"
		Invoke-Expression $functionName | Out-Null
	}
}

###########################
#
# Test-Method
#
###########################

function Test-Method($moduleName, $functionName) {
	(get-command -module $moduleName | Where-Object { $_.Name -eq "$functionName" } | Measure-Object).Count -eq 1;
}

Export-ModuleMember Reload-Module, Initialize-Modules, Test-Method, Invoke-Method