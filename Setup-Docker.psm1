function dbash {
  Param(
    [parameter(Mandatory=$true)][string]$container
  )
  
  docker exec -it $container /bin/bash
}

# Get latest container ID
function dl {
  docker ps -l -q $args
}

# Get container process
function dps  {
  docker ps $args
}

# Get process included stop container
function dpa { 
  docker ps -a $args
}

function db {
  docker build -t $arg .
}

# Get images
function di {
  docker images $args
}

# Get container IP
function dip {
  docker inspect --format '{{ .NetworkSettings.IPAddress }}' $args
}

# Run deamonized container, e.g., $dkd base /bin/echo hello
function dkd {
  docker run -d -P $args
}

# Run interactive container, e.g., $dki base /bin/bash
function dki {
  docker run --rm -i -t -P $args /bin/bash
}

# Execute interactive container, e.g., $dex base /bin/bash
function dex {
  docker exec -it $args
}

# delete all non running containers
function drm {
  docker rm $(docker ps -q -a)
}

# delete all images that are not in use
function dri {
  docker rmi $(docker images -q)
}


Set-Alias dc "docker-compose"

Export-ModuleMember -Function * -Alias *