
function Setup-Git {
	git config --global core.autocrlf true
	git config --global mergetool.p4merge.trustexitcode false
	git config --global merge.tool p4merge
	git config --global diff.tool p4merge
	git config --global difftool.prompt false
	git config --global mergetool.prompt false
	git config --global mergetool.keepbackup false
	# rebase on pull instead of merge
	git config --global branch.autosetuprebase always 
	git config --global alias.co checkout
	git config --global alias.cb 'checkout -b'
	git config --global alias.ci commit
	git config --global alias.br branch
	git config --global alias.s 'status -s'
	git config --global alias.unstage 'rm -r --cached .'
	git config --global alias.deployed '!powershell TagDeployment'
	git config --global alias.aa "!git add -A . && git status -s"
	git config --global alias.pushall '!git push --all; git push --tags'
	git config --global alias.ls '!git --no-pager log -20 --date=short --pretty=tformat:\"%C(yellow)%h%Creset - %C(yellow)%an%Creset %C(white)%ad%Creset%C(yellow)%d%Creset %Cgreen%s%Creset\"'
	git config --global alias.lg 'log --graph --abbrev-commit --date=relative --pretty=format:\"%C(yellow)%h%Creset - %C(yellow)%an%Creset%C(yellow)%d%Creset %s %Cgreen(%cr)%Creset\"'
	git config --global alias.wtf '!git reflog'
	git config --global alias.list '!powershell git show --pretty=\"format:\" --name-only $1 | Sort-Object | Get-Unique'
	git config --global alias.rs '!git remote show origin'

	$username = invoke-expression "git config --get user.name"
	if($username -eq "") {
		$username = "Not Set"
	}
	$username = Read-Host "Enter Name($username)"
	if($username) {
		git config --global user.name "'$username'"
	}

	$email = invoke-expression "git config --get user.email"
	if($email -eq "") {
		$email = "Not Set"
	}
	$email = Read-Host "Enter Email($email)"
	if($email) {
		git config --global user.email "'$email'"
	}

	if (Get-Command -CommandType Cmdlet Get-Editor -errorAction SilentlyContinue) {
		$editor = Get-Editor
		if($editor -ne $null) {
			git config --global core.editor "'$editor' -multiInst -notabbar -nosession -noPlugin"
		}
	}
}

Export-ModuleMember Setup-Git