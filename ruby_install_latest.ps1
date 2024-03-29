$url = ((Invoke-WebRequest "https://api.github.com/repos/oneclick/rubyinstaller2/releases" | ConvertFrom-Json)[0].assets | Where-Object name -match "^rubyinstaller-devkit-.*-x64.exe$").browser_download_url
Invoke-WebRequest $url -Out rubyinstaller.exe

$tag = (Invoke-WebRequest "https://api.github.com/repos/oneclick/rubyinstaller2/releases" | ConvertFrom-Json)[0].tag_name
rubyinstaller.exe /silent /dir="c:/tools/$tag"

refreshenv 
ridk install 1 3
ridk install 2

ridk enable

rm rubyinstaller.exe

pacman -S mingw-w64-x86_64-freetds
gem install tiny_tds -- --with-freetds-include=C:\Tools\Ruby31-x64\msys64\mingw64\include\freetds

# Install global gems
gem install solargraph debug gitploy
