

Run Powershell  
--------------  

Start > Run > Powershell  
  
```
Set-ExecutionPolicy remotesigned -force  
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;   
iex((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))  
iex((New-Object System.Net.WebClient).DownloadString('https://github.com/ilude/WindowsPowerShell/blob/master/ruby_install_3.1.1.1.ps1')) 
PowerShellGet\Install-Module posh-git -Scope CurrentUser -Force
PowerShellGet\Install-Module posh-docker -Scope CurrentUser -Force
cd ([environment]::GetFolderPath([environment+SpecialFolder]::MyDocuments))  
git clone git@github.com:ilude/WindowsPowerShell.git Powershell  
cd Powershell  
& $profile  
Setup-Git  
pause "Press any key to continue..."  
```

Notes on updating env vars like path and importing reg settings
```
# $machine = [EnvironmentVariableTarget]::Machine  
# $existing_path = [Environment]::GetEnvironmentVariable("Path", $machine)  
# $rubygem_path = Join-Path -Path $env:LOCALAPPDATA -childpath "chefdk\gem\ruby"  
# $rubygem_path = Get-ChildItem $rubygem_path -Recurse | Where-Object { $_.PSIsContainer -and $_.Name.EndsWith("bin")}  
# [Environment]::SetEnvironmentVariable("Path", $existing_path + ";$rubygem_path", $machine) 
# reg import .\ConEmuHere.reg 
```
