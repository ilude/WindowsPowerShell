Install Windows Powershell
--------------------------

Windows 7 & Windows Server 2008 come with powershell 2.0 installed by default

[Download Powershell 3.0](http://www.microsoft.com/en-us/download/details.aspx?id=34595) for Windows 7, Windows Server 2008 & 2012

for all others you can [download the installer here](http://support.microsoft.com/kb/968930)

Run Powershell
--------------

Start > Run > Powershell

	Set-ExecutionPolicy remotesigned
	cd ([environment]::GetFolderPath([environment+SpecialFolder]::MyDocuments))
	git clone git://github.com/ilude/WindowsPowerShell.git
	exit

restart powershell

And run the following command to setup git configuration info and aliases 

	Setup-Git