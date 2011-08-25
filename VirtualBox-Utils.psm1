function Create-VM ([Parameter(Mandatory = $True)][string]$name) {

	VBoxManage createvm --name "$name" --register --ostype "Ubuntu_64"

	VBoxManage clonehd ".\Ubuntu 11.04\Ubuntu 11.04.vdi" ".\$name\$name.vdi"

	#VBoxManage modifyvm "$name" --memory 512 --nic1 bridged --nictype1 virtio
	#VBoxManage modifyvm "$name" --bridgeadapter1 "Atheros AR5B97 Wireless Network Adapter"

	VBoxManage modifyvm "$name" --memory 512 

	VBoxManage storagectl "$name" --name "SATA Controller" --add sata
	VBoxManage storageattach "$name" --storagectl "SATA Controller" --port 0 --type hdd --medium ".\$name\$name.vdi"

	VBoxManage modifyvm "$name" --nic1 nat --nictype1 82540EM
	VBoxManage modifyvm "$name" --natpf1 "SSH Proxy,tcp,,2222,,22"

	VBoxManage modifyvm "$name" --nic2 hostonly --nictype2 82540EM

	# VBoxManage list hostonlyifs
	VBoxManage modifyvm "$name" --hostonlyadapter2 "VirtualBox Host-Only Ethernet Adapter"
}





Export-ModuleMember 