Installation And Usage
======================

Start > Run > Powershell

	Set-ExecutionPolicy remotesigned
	cd ~\documents
	git clone git://github.com/truefit/WindowsPowerShell.git

exit and restart powershell

Run the following command to setup git configuration info and aliases 

	Setup-Git
	
Then run the following command to setup the truefit certificate and netrc file for auto login to the truefit repos

	Setup-Truefit
