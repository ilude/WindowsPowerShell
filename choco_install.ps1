Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Minimal
choco install -y 7zip
choco install -y brave
choco pin add -n brave
choco install -y ccleaner
choco pin add -n ccleaner
choco install -y chocolateygui
choco install -y cobian-backup
choco install -y displayfusion

choco install -y ecm # Easy Context Menu https://www.sordum.org/7615/
winget install --id=valinet.ExplorerPatcher  -e

choco install -y notepadplusplus
choco install -y open-shell -installArgs ADDLOCAL=StartMenu
choco install -y powershell-core
choco install -y screenpresso
choco pin add -n screenpresso
choco install -y spywareblaster
choco install -y sysinternals
choco install -y tailscale
choco install -y t-clock
choco install -y teamviewer
choco pin add -n teamviewer
choco install -y vscode
choco pin add -n vscode
choco install -y vlc
choco install -y wiztree

# Probably 
choco install -y msiafterburner
choco install -y ccenhancer
choco install -y cobian-backup
choco install -y discord
choco pin add -n discord
choco install -y exoduswallet
choco install -y obsidian
choco install -y synctrayzor

# Gaming
choco install -y steam
choco pin add -n steam
choco install -y epicgameslauncher
choco pin add -n epicgameslauncher

# Video Drivers
choco feature enable -n=useRememberedArgumentsForUpgrades
cinst nvidia-display-driver --package-parameters="'/dch'" -y

# AV
choco install -y avidemux
choco install -y handbrake
choco install -y inkscape
choco install -y k-litecodecpackfull
choco install -y paint.net

# Optional Stuff
choco install -y office365business
choco pin add -n office365business

# Development Tools
choco install -y ansicon
choco install -y curl
choco install -y docker-desktop
choco pin add -n docker-desktop
choco install -y git --params "/GitAndUnixToolsOnPath /WindowsTerminal /NoShellIntegration /NoGuiHereIntegration /NoShellHereIntegration"
choco install -y jq
choco install -y microsoft-windows-terminal
choco install -y putty
choco install -y rsync
choco install -y sql-server-management-studio
choco install -y winscp
choco install -y wsl2

# Optional Dev Tools
choco install -y mysql.workbench
choco install -y P4Merge
choco install -y vagrant
choco install -y wsl-alpine
choco install -y wsl-ubuntu-2204

# VSCode plugins Optional
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


