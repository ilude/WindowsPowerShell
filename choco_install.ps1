Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

choco install -y 7zip
choco install -y avidemux
choco install -y open-shell -installArgs ADDLOCAL=StartMenu
choco install -y ccleaner
choco install -y ccenhancer
choco install -y cobian-backup
choco install -y discord
choco install -y displayfusion
choco install -y docker-desktop
choco install -y DotNet3.5
choco install -y DotNet4.6
choco install -y dotnetfx
choco install -y f.lux
choco install -y googlechrome
choco install -y handbrake
choco install -y inkscape
choco install -y k-litecodecpackfull
choco install -y mysql.workbench
choco install -y notepadplusplus
choco install -y office365business
choco install -y openvpn
choco install -y paint.net
choco install -y powershell-core
choco install -y procexp
choco install -y putty
choco install -y rsync
choco install -y rufus
choco install -y screenpresso
choco install -y spywareblaster
choco install -y steam
choco install -y sql-server-management-studio
choco install -y synctrayzor
choco install -y teamviewer
choco install -y tor-browser
choco install -y vlc
choco install -y unifying  
choco install -y winscp
choco install -y wiztree

choco install -y nvidia-geforce-now

# Development Tools
choco install -y ansicon
choco install -y chefdk 
choco install -y curl
choco install -y git --params "/GitAndUnixToolsOnPath /WindowsTerminal /NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration"
choco install -y microsoft-windows-terminal
choco install -y P4Merge
choco install -y vagrant
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
