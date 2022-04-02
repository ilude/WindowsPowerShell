$url = ((Invoke-WebRequest "https://api.github.com/repos/oneclick/rubyinstaller2/releases" | ConvertFrom-Json)[0].assets | Where-Object name -match "^rubyinstaller-devkit-.*-x64.exe$").browser_download_url
Invoke-WebRequest $url -Out rubyinstaller.exe
rubyinstaller.exe /silent /dir="c:/tools/$tag"
refreshenv 
ridk install 1 3
ridk install 2

rm rubyinstaller.exe
