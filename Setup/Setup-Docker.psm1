# Setup-Docker Module - Docker container management utilities
# Requires PowerShell 3.0+
# Requires: Docker command-line tools installed

# Execute bash in running container
function dbash {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage='Container name or ID')]
    [ValidateNotNullOrEmpty()]
    [string]$Container
  )

  try {
    $exists = docker ps -q --filter "id=$Container" --filter "name=$Container" 2>$null
    if (-not $exists) {
      Write-Error "Container '$Container' not found or not running"
      return
    }

    docker exec -it $Container /bin/bash
  }
  catch {
    Write-Error "Failed to execute bash in container '$Container': $_"
  }
}

# Get latest container ID
function dl {
  [CmdletBinding()]
  param()

  try {
    docker ps -l -q
  }
  catch {
    Write-Error "Failed to get latest container: $_"
  }
}

# Get container process
function dps {
  [CmdletBinding()]
  param()

  try {
    docker ps --format="table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.RunningFor}}\t{{.State}}\t{{.Status}}"
  }
  catch {
    Write-Error "Failed to get container processes: $_"
  }
}

# Get container process with ports
function dpsp {
  [CmdletBinding()]
  param()

  try {
    docker ps --format="table {{.Names}}\t{{.ID}}\t{{.Image}}\t{{.RunningFor}}\t{{.State}}\t{{.Status}}\t{{.Ports}}"
  }
  catch {
    Write-Error "Failed to get container processes with ports: $_"
  }
}

# Get all containers (including stopped)
function dpa {
  [CmdletBinding()]
  param()

  try {
    docker ps -a
  }
  catch {
    Write-Error "Failed to get all containers: $_"
  }
}

# Build Docker image
function db {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$false)]
    [string]$Tag = 'latest',

    [Parameter(Mandatory=$false)]
    [string]$Path = '.'
  )

  try {
    if (-not (Test-Path $Path)) {
      Write-Error "Path '$Path' does not exist"
      return
    }

    docker build -t $Tag $Path
  }
  catch {
    Write-Error "Failed to build Docker image: $_"
  }
}

# Get Docker images
function di {
  [CmdletBinding()]
  param()

  try {
    docker images
  }
  catch {
    Write-Error "Failed to get Docker images: $_"
  }
}

# Get container IP address
function dip {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage='Container name or ID')]
    [ValidateNotNullOrEmpty()]
    [string]$Container
  )

  try {
    docker inspect --format '{{ .NetworkSettings.IPAddress }}' $Container
  }
  catch {
    Write-Error "Failed to get IP for container '$Container': $_"
  }
}

# Run daemonized container
function dkd {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
  )

  try {
    docker run -d -P $Arguments
  }
  catch {
    Write-Error "Failed to run daemonized container: $_"
  }
}

# Run interactive container
function dki {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Arguments
  )

  try {
    docker run --rm -i -t -P $Arguments /bin/bash
  }
  catch {
    Write-Error "Failed to run interactive container: $_"
  }
}

# Execute interactive command in running container
function dex {
  [CmdletBinding()]
  param(
    [Parameter(Mandatory=$true, ValueFromPipeline=$true, HelpMessage='Container name or ID')]
    [ValidateNotNullOrEmpty()]
    [string]$Container,

    [Parameter(Mandatory=$true, ValueFromRemainingArguments=$true)]
    [string[]]$Command
  )

  try {
    $exists = docker ps -q --filter "id=$Container" --filter "name=$Container" 2>$null
    if (-not $exists) {
      Write-Error "Container '$Container' not found or not running"
      return
    }

    docker exec -it $Container $Command
  }
  catch {
    Write-Error "Failed to execute command in container '$Container': $_"
  }
}

# Delete all non-running containers
function drm {
  [CmdletBinding()]
  param()

  try {
    $containers = docker ps -q -a
    if (-not $containers) {
      Write-Host "No containers to delete"
      return
    }

    docker rm $containers
  }
  catch {
    Write-Error "Failed to remove containers: $_"
  }
}

# Delete all unused images
function dri {
  [CmdletBinding()]
  param()

  try {
    $images = docker images -q
    if (-not $images) {
      Write-Host "No images to delete"
      return
    }

    docker rmi $images
  }
  catch {
    Write-Error "Failed to remove images: $_"
  }
}

# Docker compose alias
Set-Alias dc "docker compose"

Export-ModuleMember -Function * -Alias *
