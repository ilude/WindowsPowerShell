# Setup-Unix Module - Unix-like command wrappers for PowerShell
# Requires PowerShell 3.0+
# Provides: which, Get-NetworkStatistics (alias: listen)

###########################
#
# which
#
###########################

function which {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
    [ValidateNotNullOrEmpty()]
    [string]$Name
  )

  try {
    $cmd = Get-Command $Name -ErrorAction Stop
    $cmd | Select-Object -ExpandProperty Definition
  }
  catch {
    Write-Error "Command '$Name' not found: $_"
  }
}

###########################
#
# Get-NetworkStatistics
# Displays listening ports and associated processes
# http://blogs.microsoft.co.il/blogs/scriptfanatic/archive/2011/02/10/How-to-find-running-processes-and-their-port-number.aspx
#
###########################

function Get-NetworkStatistics {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$false)]
    [ValidateSet('TCP', 'UDP')]
    [string]$Protocol = '*'
  )

  try {
    $properties = 'Protocol', 'LocalAddress', 'LocalPort'
    $properties += 'RemoteAddress', 'RemotePort', 'State', 'ProcessName', 'PID'

    netstat -ano | Select-String -Pattern '\s+(TCP|UDP)' | ForEach-Object {
      try {
        $item = $_.line.split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)

        if ($item[1] -notmatch '^\[::') {
          # Handle IPv6 addresses
          if (($la = $item[1] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') {
            $localAddress = $la.IPAddressToString
            $localPort = $item[1].split('\]:')[-1]
          }
          else {
            $localAddress = $item[1].split(':')[0]
            $localPort = $item[1].split(':')[-1]
          }

          # Handle remote address
          if (($ra = $item[2] -as [ipaddress]).AddressFamily -eq 'InterNetworkV6') {
            $remoteAddress = $ra.IPAddressToString
            $remotePort = $item[2].split('\]:')[-1]
          }
          else {
            $remoteAddress = $item[2].split(':')[0]
            $remotePort = $item[2].split(':')[-1]
          }

          # Get process name safely
          $processName = 'N/A'
          try {
            $process = Get-Process -Id $item[-1] -ErrorAction SilentlyContinue
            if ($process) {
              $processName = $process.Name
            }
          }
          catch {
            # Process may not exist or access denied - use N/A
          }

          $protocolType = $item[0]

          # Filter by protocol if specified
          if ($Protocol -eq '*' -or $protocolType -eq $Protocol) {
            New-Object PSObject -Property @{
              PID           = $item[-1]
              ProcessName   = $processName
              Protocol      = $protocolType
              LocalAddress  = $localAddress
              LocalPort     = $localPort
              RemoteAddress = $remoteAddress
              RemotePort    = $remotePort
              State         = if ($protocolType -eq 'tcp') { $item[3] } else { $null }
            } | Select-Object -Property $properties
          }
        }
      }
      catch {
        # Skip malformed lines
        Write-Verbose "Skipped malformed netstat line: $_"
      }
    }
  }
  catch {
    Write-Error "Failed to get network statistics: $_"
  }
}

Set-Alias listen Get-NetworkStatistics

Export-ModuleMember -Function which, Get-NetworkStatistics -Alias which, listen
