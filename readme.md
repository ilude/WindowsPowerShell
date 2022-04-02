

Run Powershell  
--------------  

Start > Run > Powershell  
  
```
Set-ExecutionPolicy remotesigned -force  
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;   
# iex((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  
# $machine = [EnvironmentVariableTarget]::Machine  
# $existing_path = [Environment]::GetEnvironmentVariable("Path", $machine)  
# $rubygem_path = Join-Path -Path $env:LOCALAPPDATA -childpath "chefdk\gem\ruby"  
# $rubygem_path = Get-ChildItem $rubygem_path -Recurse | Where-Object { $_.PSIsContainer -and $_.Name.EndsWith("bin")}  
# [Environment]::SetEnvironmentVariable("Path", $existing_path + ";$rubygem_path", $machine) 
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
cd ([environment]::GetFolderPath([environment+SpecialFolder]::MyDocuments))  
git clone git@github.com:ilude/WindowsPowerShell.git Powershell  
cd Powershell  
# reg import .\ConEmuHere.reg  
& $profile  
Setup-Git  
pause "Press any key to continue..."  
```
