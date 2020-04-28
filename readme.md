

Run Powershell
--------------

Start > Run > Powershell

	Start-Process powershell -Verb runAs
	Set-ExecutionPolicy remotesigned -force
	Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; 
	iex((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
	choco install powershell-core -y
	choco install git -y

	cd ([environment]::GetFolderPath([environment+SpecialFolder]::MyDocuments))
	git clone git://github.com/ilude/WindowsPowerShell.git Powershell
	& $profile
	Setup-Git
	exit
