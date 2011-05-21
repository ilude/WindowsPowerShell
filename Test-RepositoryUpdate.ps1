$remote=$(git ls-remote origin HEAD | %{ $_.Split(',')[0]; })
$local=$(git rev-parse HEAD)

$remote -eq $master