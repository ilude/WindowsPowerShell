

Run Powershell  
--------------  

Start > Run > Powershell  
  
```
Set-ExecutionPolicy remotesigned -force  
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;
iex((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
PowerShellGet\Install-Module posh-docker -Scope CurrentUser -Force

choco install -y powershell-core
choco install -y git --params "/GitAndUnixToolsOnPath /WindowsTerminal /NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration"

cd ([environment]::GetFolderPath([environment+SpecialFolder]::MyDocuments))  
mkdir -p Powershell -f | out-null
cd Powershell

git init
git config --global --add safe.directory ([environment]::GetFolderPath([environment+SpecialFolder]::MyDocuments))/Powershell
git remote add origin https://github.com/ilude/WindowsPowerShell.git
git fetch
git reset --hard origin/master
env
Setup-Git  
pause "Press any key to continue..."  
```
