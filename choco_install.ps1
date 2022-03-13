Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# minimal
choco install -y 7zip
choco install -y open-shell -installArgs ADDLOCAL=StartMenu
choco install -y brave
choco install -y ccleaner
choco install -y discord
choco install -y epicgameslauncher
choco install -y k-litecodecpackfull
choco install -y notepadplusplus
choco install -y obsidian
choco install -y paint.net
choco install -y powershell-core
choco install -y screenpresso
choco install -y spywareblaster
choco install -y steam
choco install -y synctrayzor
choco install -y t-clock
choco install -y teamviewer
choco install -y vlc
choco install -y wiztree

choco install -y avidemux
choco install -y ccenhancer
choco install -y cobian-backup
choco install -y displayfusion
choco install -y handbrake
choco install -y inkscape
choco install -y office365business
choco install -y openvpn
choco install -y procexp # Process Explorer - SysInternals
choco install -y rufus
choco install -y sql-server-management-studio

choco install -y nvidia-geforce-now
choco install -y unifying 

# Development Tools
# choco install -y chefdk 
choco install -y ansicon
choco install -y curl
choco install -y docker-desktop
choco install -y git --params "/GitAndUnixToolsOnPath /WindowsTerminal /NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration"
choco install -y microsoft-windows-terminal
choco install -y mysql.workbench
choco install -y P4Merge
choco install -y putty
choco install -y ruby
choco install -y rsync
choco install -y vagrant
choco install -y winscp
choco install -y wsl2
choco install -y wsl-ubuntu-2004

# VSCode and plugins
choco install vscode
choco install vscode-gitignore
choco install vscode-ansible
choco install vscode-ruby
choco install vscode-yaml
choco install vscode-gitattributes
choco install vscode-codespellchecker
choco install vscode-gitlens
choco install vscode-powershell
choco install vscode-icons

#iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ilude/WindowsPowerShell/master/choco_install_development.ps1'))
