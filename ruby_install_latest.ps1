$url = ((Invoke-WebRequest "https://api.github.com/repos/oneclick/rubyinstaller2/releases" | ConvertFrom-Json)[0].assets | Where-Object name -match "^rubyinstaller-devkit-.*-x64.exe$").browser_download_url
Invoke-WebRequest $url -Out rubyinstaller.exe

$tag = (Invoke-WebRequest "https://api.github.com/repos/oneclick/rubyinstaller2/releases" | ConvertFrom-Json)[0].tag_name
rubyinstaller.exe /silent /dir="c:/tools/$tag"

refreshenv 
ridk install 1 3
ridk install 2

rm rubyinstaller.exe


# Install global gems
gem install solargraph debug gitploy

# install Chocolatey 
iex((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
refreshenv
choco install make -y

# powershell quality of life improvements
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
PowerShellGet\Install-Module posh-docker -Scope CurrentUser -Force
