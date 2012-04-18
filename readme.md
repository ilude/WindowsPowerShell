Install Windows Powershell
--------------------------

Windows 7 & Windows Server 2008 come with powershell installed by default

for all others you can [download the installer here](http://support.microsoft.com/kb/968930)

Run Powershell
--------------

Start > Run > Powershell

	Set-ExecutionPolicy remotesigned
	cd ([environment]::GetFolderPath([environment+SpecialFolder]::MyDocuments))
	git clone git://github.com/truefit/WindowsPowerShell.git
	exit

restart powershell

And run the following command to setup git configuration info and aliases 

	Setup-Git