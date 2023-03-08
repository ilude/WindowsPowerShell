# install Chocolatey
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

choco install -y 7zip
choco install -y open-shell -installArgs ADDLOCAL=StartMenu
#choco install -y brave
#choco install -y ccleaner
choco install -y notepadplusplus
choco install -y powershell-core
#choco install -y procexp
#choco install -y t-clock
choco install -y wiztree
choco install -y rustdesk

#choco install -y teamviewer

# Activate Windows Server
DISM.exe /Online /Get-TargetEditions
DISM /online /Set-Edition:ServerStandard /ProductKey:ENTER-YOUR-SERIAL-KEY-HERE /AcceptEula
