

Run Powershell  
--------------  

Start > Run > Powershell  
  
```
Set-ExecutionPolicy remotesigned -force  
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;   
iex((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  
iex((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ilude/WindowsPowerShell/master/ruby_install_3.1.1.1.ps1')) 
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
PowerShellGet\Install-Module posh-docker -Scope CurrentUser -Force
cd ([environment]::GetFolderPath([environment+SpecialFolder]::MyDocuments))  
mkdir -p Powershell -f | out-null
cd Powershell
git init
git config --global --add safe.directory ([environment]::GetFolderPath([environment+SpecialFolder]::MyDocuments))/Powershell
git remote add origin https://github.com/ilude/WindowsPowerShell.git
git fetch
git reset --hard origin/master
& $profile  
Setup-Git  
pause "Press any key to continue..."  
```

Notes on updating env vars like path and importing reg settings
```
# reg import .\ConEmuHere.reg 
```
