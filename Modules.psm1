###########################
#
# Reload-Module
#
###########################

function Reload-Module($ModuleName) {
	if((get-module -all | where{$_.name -eq "$ModuleName"} | measure-object).count -gt 0) {
		
		remove-module $ModuleName
		Write-Verbose "Module $ModuleName Unloaded"
		
		$current_directory = Get-ScriptDirectory
		$file_path = $ModuleName;
		if(Test-Path (join-Path $current_directory "$ModuleName.psm1")) {
			$file_path = (join-Path $current_directory "$ModuleName.psm1")
		}
		
		import-module "$file_path" -DisableNameChecking -verbose:$false
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