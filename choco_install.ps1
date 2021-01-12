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

iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/ilude/WindowsPowerShell/master/choco_install_development.ps1'))
