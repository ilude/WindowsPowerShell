


remove-item alias:head 	-ErrorAction SilentlyContinue
remove-item alias:rm 		-ErrorAction SilentlyContinue
remove-item alias:wc 		-ErrorAction SilentlyContinue


Set-Alias which get-command

function grep {
	Param
	(
		[Parameter(Position=0, Mandatory = $true)]
		[string]$pattern,
		[Parameter(Position=1, Mandatory = $true)]
		[string]$filefilter,
		[switch]$r, # Recurse
		[switch]$i, # Ignore case
		[switch]$l  # List filenames
	)

	$path = $pwd 

	# need to add filter for files only, no directories
	$files = Get-ChildItem $path -include "$filefilter" -recurse:$r 
	if($l){
		$files | foreach {
			if($(Get-Content $_ | select-string -pattern $pattern -caseSensitive:$i).Count > 0){
				$_ | Select-Object path
			}
		}
		select-string $pattern $files -caseSensitive:$i 
	}
	else {
		$files | foreach {
			$_ | select-string -pattern $pattern -caseSensitive:$i 
		}
	}
}

function head {
	Param(
		[parameter(Mandatory=$true)][string]$file,
		[int]$count = 10
	)
	
	if((Test-Path $file) -eq $False) {
		Write-Error "Unable to locate file $file"
		return;
	}
	
	return Get-Content $file | Select-Object -First $count
}

function rm {
	Param
	(
		[swtich]$r=$false,
		[Parameter(Mandatory = $True)]
		[string]$pattern
	)


	if($r) {
		$files = Get-ChildItem $pwd -include $pattern -Recurse -Force
	}
	else {
		$files = Get-ChildItem $pwd -include $pattern -Force
	}

	$files | Remove-Item -Recurse -Force
}

function wc {
	param($object)

	begin {
		# initialize counter for counting number of data from
		$counter = 0
	}

	# Process is invoked for every pipeline input
	process {
		if ($_) { $counter++ }
	}

	end {
		# if "wc" has an argument passed, ignore pipeline input
		if ($object) {
			if(Test-Path $object){
				(Get-Content $object | Measure-Object).Count
			}
			else {
				($object | Measure-Object).Count
			}
			
		} else {
			$counter
		}
	}
}