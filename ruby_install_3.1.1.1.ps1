Invoke-WebRequest "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.1.1-1/rubyinstaller-devkit-3.1.1-1-x64.exe" -Out rubyinstaller.exe
./rubyinstaller.exe /silent /dir="c:/tools/ruby-3.1.1-1"
refreshenv 
# $env:Path += ";c:\tools\ruby-3.1.1-1\bin"
ridk install 1 3
ridk install 2

rm rubyinstaller.exe
