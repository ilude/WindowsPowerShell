Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# minimal
choco install -y 7zip
choco install -y open-shell -installArgs ADDLOCAL=StartMenu
choco install -y brave
choco pin add -n brave
choco install -y ccleaner
choco pin add -n ccleaner
choco install -y discord
choco pin add -n discord
choco install -y epicgameslauncher
choco pin add -n epicgameslauncher
choco install -y k-litecodecpackfull
choco install -y notepadplusplus
choco install -y obsidian
choco install -y paint.net
choco install -y powershell-core
choco install -y screenpresso
choco pin add -n screenpresso
choco install -y spywareblaster
choco install -y steam
choco pin add -n steam
choco install -y synctrayzor
choco install -y t-clock
choco install -y teamviewer
choco pin add -n teamviewer
choco install -y vlc
choco install -y wiztree

choco install -y avidemux
choco install -y ccenhancer
choco install -y cobian-backup
choco install -y displayfusion
choco install -y exoduswallet
choco install -y handbrake
choco install -y inkscape
choco install -y office365business
choco pin add -n office365business
choco install -y openvpn
choco install -y procexp # Process Explorer - SysInternals
choco install -y rufus

choco install -y nvidia-geforce-now
choco pin add -n nvidia-geforce-now
choco install -y unifying 

# Development Tools
# choco install -y chefdk 
choco install -y ansicon
choco install -y curl
choco install -y docker-desktop
choco pin add -n docker-desktop
choco install -y git --params "/GitAndUnixToolsOnPath /WindowsTerminal /NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration"
choco install -y microsoft-windows-terminal
choco install -y mysql.workbench
choco install -y P4Merge
choco install -y putty
choco install -y rsync
choco install -y sql-server-management-studio
choco install -y winscp
choco install -y wsl2

# VSCode and plugins
choco install -y vscode
choco pin add -n vscode
choco install -y vscode-gitignore
choco pin add -n vscode-gitignore
choco install -y vscode-ansible
choco pin add -n vscode-ansible
choco install -y vscode-ruby
choco pin add -n vscode-ruby
choco install -y vscode-yaml
choco pin add -n vscode-yaml
choco install -y vscode-gitattributes
choco pin add -n vscode-gitattributes
choco install -y vscode-codespellchecker
choco pin add -n vscode-codespellchecker
choco install -y vscode-gitlens
choco pin add -n vscode-gitlens
choco install -y vscode-powershell
choco pin add -n vscode-powershell
choco install -y vscode-icons
choco pin add -n vscode-icons

# Optional Dev Tools
choco install -y vagrant
choco install -y wsl-alpine
choco install -y wsl-ubuntu-2004


#iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ilude/WindowsPowerShell/master/choco_install_development.ps1'))
