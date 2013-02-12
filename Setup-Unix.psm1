
###########################
#
# which
#
###########################

Set-Alias which get-command

###########################
#
# grep
#
###########################

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

###########################
#
# head
#
###########################

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

###########################
#
# rm
#
###########################

function rm {
	Param
	(
		[swtich]$r=$false,
		[Parameter(Mandatory = $True)]
		[string]$pattern
	)

	if($r) {
		Get-ChildItem $pwd -include $pattern -Recurse -Force | Remove-Item 
	}
	else {
		Get-ChildItem $pwd -include $pattern -Force | Remove-Item 
	}
}

###########################
#
# wc
#
###########################

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

###########################
#
# netstat
# http://blogs.microsoft.co.il/blogs/scriptfanatic/archive/2011/02/10/How-to-find-running-processes-and-their-port-number.aspx
# Get-NetworkStatistics | where-object {$_.State -eq "LISTENING"} | Format-Table
###########################

function Get-NetworkStatistics 
{ 
    $properties = 'Protocol','LocalAddress','LocalPort' 
    $properties += 'RemoteAddress','RemotePort','State','ProcessName','PID' 

    netstat -ano | Select-String -Pattern '\s+(TCP|UDP)' | ForEach-Object { 

        $item = $_.line.split(" ",[System.StringSplitOptions]::RemoveEmptyEntries) 

        if($item[1] -notmatch '^\[::') 
        {            
            if (($la = $item[1] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') 
            { 
               $localAddress = $la.IPAddressToString 
               $localPort = $item[1].split('\]:')[-1] 
            } 
            else 
            { 
                $localAddress = $item[1].split(':')[0] 
                $localPort = $item[1].split(':')[-1] 
            }  

            if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') 
            { 
               $remoteAddress = $ra.IPAddressToString 
               $remotePort = $item[2].split('\]:')[-1] 
            } 
            else 
            { 
               $remoteAddress = $item[2].split(':')[0] 
               $remotePort = $item[2].split(':')[-1] 
            }  

            New-Object PSObject -Property @{ 
                PID = $item[-1] 
                ProcessName = (Get-Process -Id $item[-1] -ErrorAction SilentlyContinue).Name 
                Protocol = $item[0] 
                LocalAddress = $localAddress 
                LocalPort = $localPort 
                RemoteAddress =$remoteAddress 
                RemotePort = $remotePort 
                State = if($item[0] -eq 'tcp') {$item[3]} else {$null} 
            } | Select-Object -Property $properties 
        } 
    } 
}

Set-Alias listen Get-NetworkStatistics

Export-ModuleMember grep, head, rm, wc, Get-NetworkStatistics -Alias which, listen