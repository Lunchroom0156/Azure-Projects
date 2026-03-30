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

# Create resource group
$rg = new-azResourceGroup -Name backup-lab -Location ukwest  

$vnet = new-azvirtualNetwork -ResourceGroupName backup-lab -Location uksouth -Name vnet1 -AddressPrefix 10.0.0.0/16 

$subnet = Add-AzVirtualNetworkSubnetConfig -AddressPrefix 10.0.0.0/24  -Name Subnet1 -VirtualNetwork $vnet         

Set-AzVirtualNetwork -VirtualNetwork $subnet

New-AzVm `
    -ResourceGroupName 'Backup-lab' `
    -Name 'myVM' `
    -Location 'ukwest' `
    -Image 'MicrosoftWindowsServer:WindowsServer:2022-datacenter-azure-edition:latest' `
    -VirtualNetworkName 'vnet1' `
    -SubnetName 'subnet1' `
    -SecurityGroupName 'myNetworkSecurityGroup' `
    -OpenPorts 80,3389

 New-AzRecoveryServicesVault -Name RSVault -ResourceGroupName $rg -Location ukwest 

# Set Vault Context
 Get-AzRecoveryServicesVault -Name "RSVault" | Set-AzRecoveryServicesVaultContext

# Get Backup policy
 $policy = Get-AzRecoveryServicesBackupProtectionPolicy -Name "DefaultPolicy"

# Enable protection and apply the policy
 Enable-AzRecoveryServicesBackupProtection -ResourceGroupName "backup-lab" -Name $vmname -Policy $policy

# Find the container 
 $container = get-azrecovveryservicesbackupcontainer -containertype "AzureVM" -friendlyName $vmName

# Get backup item
$item = Get-AzRecoveryServicesBackupItem  -Container $container -WorkloadType "AzureVM"

# Backup item & monitor job
 Backup-AzRecoveryServicesBackupItem -Item $item
 Get-AzRecoveryServicesBackupJob -Status InProgress

# ---
# Create recovery service vault in desitation 
 New-AzRecoveryServicesVault -Name RSVault-ASR -ResourceGroupName backup-lab -Location uksouth
 Set-AzRecoveryServicesAsrVaultContext -Vault $asrVault

