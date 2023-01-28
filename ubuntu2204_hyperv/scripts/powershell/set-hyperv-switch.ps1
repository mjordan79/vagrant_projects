# See: https://www.thomasmaurer.ch/2016/01/change-hyper-v-vm-switch-of-virtual-machines-using-powershell/
$virtualmachine=$args[0]
Write-Host "Linking the switch to the $virtualmachine environment..."
Get-VM $virtualmachine | Get-VMNetworkAdapter | Connect-VMNetworkAdapter -SwitchName "LabSwitch"