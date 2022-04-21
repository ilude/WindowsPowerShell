# Install the latest version of ruby with devkit 
$ruby_version = '3.1.2-1'

Invoke-WebRequest "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.1.2-1/rubyinstaller-devkit-$ruby_version-x64.exe" -Out rubyinstaller.exe
./rubyinstaller.exe /silent /dir="c:/tools/ruby-$ruby_version"
refreshenv 
. "C:\Tools\ruby-$ruby_version\bin\ridk" install 1 3
refreshenv 
. "C:\Tools\ruby-$ruby_version\bin\ridk" install 2

rm ./rubyinstaller.exe
refreshenv 

# Install global gems
gem install solargraph debug gitploy

# Install mutagen for docker volumn shares that work with file system change notification
Invoke-WebRequest  https://github.com/mutagen-io/mutagen/releases/download/v0.13.1/mutagen_windows_amd64_v0.13.1.zip -Out mutagen.zip
Invoke-WebRequest  https://github.com/mutagen-io/mutagen-compose/releases/download/v0.13.1/mutagen-compose_windows_amd64_v0.13.1.zip -Out mutagen-compose.zip

unzip mutagen.zip 
unzip mutagen-compose.zip
rm mutagen.zip
rm mutagen-compose.zip

cp mutagen*.* "C:\Tools\ruby-$ruby_version\bin\" -force
rm mutagen*.*

# install Chocolatey 
iex((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
refreshenv
choco install make -y

# powershell quality of life improvements
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
PowerShellGet\Install-Module posh-docker -Scope CurrentUser -Force
