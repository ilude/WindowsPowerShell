Write-Host Determining latest release
$tag = (Invoke-WebRequest "https://api.github.com/repos/oneclick/rubyinstaller2/releases" | ConvertFrom-Json)[0].tag_name
# https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.1.1-1/rubyinstaller-3.1.1-1-x64.exe

$filename = "$tag-x64.exe"
$download = "https://github.com/oneclick/rubyinstaller2/releases/download/$tag/$tag-x64.exe"


Write-Host Dowloading latest release
Invoke-WebRequest $download -Out rubyinstaller.exe

rubyinstaller.exe /silent /dir="c:/tools/$tag"
Update-SessionEnvironment
ridk install 1 3
Update-SessionEnvironment

rm rubyinstaller.exe
