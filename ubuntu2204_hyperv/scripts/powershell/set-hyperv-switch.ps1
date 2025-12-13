# See: https://www.thomasmaurer.ch/2016/01/change-hyper-v-vm-switch-of-virtual-machines-using-powershell/
$virtualmachine=$args[0]
Write-Host "`e[36mLinking the switch to the $virtualmachine environment...`e[0m"
Get-VM $virtualmachine | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "LabSwitch"