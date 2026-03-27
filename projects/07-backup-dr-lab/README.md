# Backup & Disaster Recovery Lab

## Objective
Implement Azure Backup and Site Recovery for business continuity.

## Tasks
1. Configure Azure Backup for VMs and storage.
2. Set up Azure Site Recovery for failover.
3. Test failover and recovery scenarios.

## Skills Covered
- Backup and Recovery
- Disaster Recovery Planning
- Replication

## Scripts
- `scripts/backup-setup.ps1` → PowerShell script to configure backups and DR

new-azResourceGroup -Name backup-lab -Location uksouth   

$vnet = new-azvirtualNetwork -ResourceGroupName backup-lab -Location uksouth -Name vnet1 -AddressPrefix 10.0.0.0/16 

$subnet = Add-AzVirtualNetworkSubnetConfig -AddressPrefix 10.0.0.0/24  -Name Subnet1 -VirtualNetwork $vnet         

Set-AzVirtualNetwork -VirtualNetwork $vnet

New-AzVm `
    -ResourceGroupName 'Backup-lab' `
    -Name 'myVM' `
    -Location 'uksouth' `
    -Image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
    -VirtualNetworkName 'vnet1' `
    -SubnetName 'subnet1' `
    -SecurityGroupName 'myNetworkSecurityGroup' `
    -PublicIpAddressName 'myPublicIpAddress' `
    -OpenPorts 80,3389
