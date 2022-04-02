Invoke-WebRequest "https://github.com/oneclick/rubyinstaller2/releases/download/RubyInstaller-3.1.1-1/rubyinstaller-3.1.1-1-x64.exe" -Out rubyinstaller.exe
rubyinstaller.exe /silent /dir="c:/tools/ruby--3.1.1-1"
Update-SessionEnvironment
ridk install 1 3
Update-SessionEnvironment

rm rubyinstaller.exe
