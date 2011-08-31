Install Windows Powershell
--------------------------

Windows 7 & Windows Server 2008 come with powershell installed by default

for all others you can [download the installer here](http://support.microsoft.com/kb/968930)

Run Powershell
--------------

Start > Run > Powershell

	Set-ExecutionPolicy remotesigned
	cd ~\documents
	git clone git://github.com/truefit/WindowsPowerShell.git
	exit

restart powershell

And run the following command to setup git configuration info and aliases 

	Setup-Git
	
Then run the following command to setup the truefit certificate and netrc file for auto login to the truefit repos

	Setup-Truefit
