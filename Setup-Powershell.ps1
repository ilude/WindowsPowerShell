function New-OpenPowerShellContextMenuEntry
{
    param($Path)

    New-Item $Path -ItemType RegistryKey -Force
    New-ItemProperty $Path -Name '(Default)' -Value 'PowerShell Here'
    New-Item $Path\Command -ItemType RegistryKey
    New-ItemProperty $Path\Command -Name '(Default)' `
        -Value "`"$pshome\powershell.exe`" -NoExit -Command [Environment]::CurrentDirectory=(Set-Location -LiteralPath:'%L' -PassThru).ProviderPath"
}

New-OpenPowerShellContextMenuEntry 'HKCU:\Software\Classes\Directory\shell\PowerShell'
New-OpenPowerShellContextMenuEntry 'HKCU:\Software\Classes\Drive\shell\PowerShell'