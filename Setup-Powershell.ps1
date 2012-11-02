function New-OpenPowerShellContextMenuEntry
{
    param($Path)

    New-Item $Path -ItemType RegistryKey -Force
    New-ItemProperty $Path -Name '(Default)' -Value 'Console2 Here'
    New-ItemProperty $Path -Name 'Icon' -Value 'C:\Program Files\Console2\Console.exe,0'
    New-Item $Path\Command -ItemType RegistryKey
    New-ItemProperty $Path\Command -Name '(Default)' `
        -Value "C:\Program Files\Console2\ansicon.exe C:\Program Files\Console2\Console.exe -d `"%L`""
}

New-OpenPowerShellContextMenuEntry 'HKCU:\Software\Classes\Directory\shell\PowerShell'
New-OpenPowerShellContextMenuEntry 'HKCU:\Software\Classes\Drive\shell\PowerShell'
