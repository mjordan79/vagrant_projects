# See: https://www.petri.com/using-nat-virtual-switch-hyper-v

# If you want to create the virtual switch manually:
# Creates a new virtual switch on one or more virtual machine hosts.
# This internal switch is associated to an adapter which will use a NAT to translate internal addresses for
# external communication.
# New-VMSwitch -SwitchName LabSwitch -SwitchType Internal

# Lists all switches, including the one created before showing also its InterfaceIndex number for reference.
# Get-NetAdapter

# Creates a new IP address associated with the adapter created before. This IP is the gateway while
# the prefixlenghth represents the netmask (24 = 255.255.255.0)
# New-NetIPAddress -IPAddress 192.169.0.1 -PrefixLength 24 -InterfaceIndex 51

# Creates a new NAT associated to the adapter and using the IP range specified in the adapter.
# New-NetNat -Name LabNAT -InternalIPInterfaceAddressPrefix 192.169.0.0/24

# If you want to clean manually this stuff, in Powershell you can use:
# Remove-NetIPAddress -InterfaceAlias "vEthernet (LabSwitch)" -IPAddress 192.169.0.1  
# Remove-VMSwitch "LabSwitch"
# Get-NetNat
# Remove-NetNat LabNAT
# Get-VMSwitch

If ("LabSwitch" -in (Get-VMSwitch | Select-Object -ExpandProperty Name) -eq $FALSE) {
    'Creating Internal-only switch named "LabSwitch" on Windows Hyper-V host...'

    New-VMSwitch -SwitchName "LabSwitch" -SwitchType Internal

    New-NetIPAddress -IPAddress 192.169.0.1 -PrefixLength 24 -InterfaceAlias "vEthernet (LabSwitch)"

    New-NetNAT -Name "LabNAT" -InternalIPInterfaceAddressPrefix 192.169.0.0/24
}
else {
    '"LabSwitch" for static IP configuration already exists: skipping.'
}

If ("192.169.0.1" -in (Get-NetIPAddress | Select-Object -ExpandProperty IPAddress) -eq $FALSE) {
    'Registering new IP address 192.169.0.1 on Windows Hyper-V host...'

    New-NetIPAddress -IPAddress 192.169.0.1 -PrefixLength 24 -InterfaceAlias "vEthernet (LabSwitch)"
}
else {
    '"192.169.0.1" for static IP configuration already registered: skipping.'
}

If ("192.169.0.0/24" -in (Get-NetNAT | Select-Object -ExpandProperty InternalIPInterfaceAddressPrefix) -eq $FALSE) {
    'Registering new NAT adapter for 192.169.0.0/24 on Windows Hyper-V host...'

    New-NetNAT -Name "LabNAT" -InternalIPInterfaceAddressPrefix 192.169.0.0/24
}
else {
    '"192.169.0.0/24" for static IP configuration already registered: skipping.'
}
