# Script for Project 01 - Virtual Network Security Lab
# version: 1.0
# date: 02.01.2026

# Force import Az 10.2.0
Import-Module Az -RequiredVersion 10.2.0 -Force

#-----------------------------------
# Connect to Azure account
#-----------------------------------
Connect-AzAccount
#-----------------------------------
# Variables 
#-----------------------------------
$RG = 'Project01-RG'
$Location = 'UKSouth'

# Create the resource group
New-AzResourceGroup -name $RG -Location $Location

#-----------------------------------
# VNET1 
#----------------------------------

# Create VNET1 with subnet1
$VNET1Subnet = New-AzVirtualNetworkSubnetConfig -Name subnet1 -AddressPrefix '10.0.0.0/24'
$VNET1 = New-AzVirtualNetwork -Name 'vnet1' -AddressPrefix '10.0.0.0/16' -ResourceGroupName $RG -location $Location -Subnet $VNET1Subnet

# Create nsg and nsg rules
$rule1 = New-AzNetworkSecurityRuleConfig -name 'Allow-RDP' -Access Allow -Protocol TCP -Priority 100 -SourceAddressPrefix '*' -DestinationAddressPrefix '10.0.0.0/24' -DestinationPortRange 3389 -Direction Inbound -SourcePortRange '*'
$nsg1 = New-AzNetworkSecurityGroup -Name 'Vnet1-nsg' -Location $Location -ResourceGroupName $RG -SecurityRules $rule1

# Associate subnet with vnet
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNET1 -Name 'subnet1' -AddressPrefix 10.0.0.0/24 -NetworkSecurityGroup $nsg1

# Update VNET to apply the subnet changes
$VNET1 | Set-AzVirtualNetwork

#--------------------------------------
# VNET2
#--------------------------------------

# Create VNET2 with subnet2
$VNET2Subnet = New-AzVirtualNetworkSubnetConfig -Name 'subnet2' -AddressPrefix '10.1.0.0/24'
$VNET2 = New-AzVirtualNetwork -Name vnet2 -AddressPrefix '10.1.0.0/16' -ResourceGroupName $RG -location $Location -Subnet $VNET2Subnet

# Create nsg 
$nsg2 = New-AzNetworkSecurityGroup -Name 'Vnet2-nsg' -Location $Location -ResourceGroupName $RG 

# Associate subnet with vnet
Set-AzVirtualNetworkSubnetConfig -VirtualNetwork $VNET2 -Name 'subnet2' -AddressPrefix 10.1.0.0/24 -NetworkSecurityGroup $nsg2


# Update VNET to apply the subnet changes
$VNET2 | Set-AzVirtualNetwork

# ----------------------------
# Create firewall subnets
# -----------------------------
$FWSubnet1 = New-AzVirtualNetworkSubnetConfig -Name 'AzureFirewallSubnet' -AddressPrefix '10.0.255.0/26'
$FWSubnet2 = New-AzVirtualNetworkSubnetConfig -Name 'AzureFirewallSubnet' -AddressPrefix '10.1.255.0/26'

# Add the firwall subnet to the existing VNet
$VNET1 | Add-AzVirtualNetworkSubnetConfig -Subnet $FWSubnet1
$VNET2 | Add-AzVirtualNetworkSubnetConfig -Subnet $FWSubnet2

# Apply the change
$VNET1 | Set-AzVirtualNetwork
$VNET2 | Set-AzVirtualNetwork
#--------------------------------------
# VNET firewall
#--------------------------------------
$VNET1 = Get-AzVirtualNetwork -Name 'vnet1' -ResourceGroupName $RG
$FWpip = New-AzPublicIpAddress -Name 'fw-pip' -ResourceGroupName $RG -location $Location -sku 'standard' -AllocationMethod Static
$FW = New-Azfirewall -name 'vnet01-fw' -ResourceGroupName $RG -Location $Location -VirtualNetwork $VNET1 -PublicIpAddress $FWpip
#--------------------------------------
# VNET firewall policy
#--------------------------------------
$Fwpolicy = New-AzFirewallPolicy -Name 'fwpolicy' -ResourceGroupName $RG -Location $Location
#--------------------------------------
# VNET firewall rule collection
#--------------------------------------
$FWRule1 = New-AzFirewallNetworkRule -Name 'Allow-TCP-Internet-VNET1-3389' -Protocol 'TCP' -SourceAddress '*' -DestinationAddress '10.0.0.0/24','10.1.0.0/24' -DestinationPort 3389
$FWRuleCollection = New-AzFirewallPolicyNetworkRuleCollection -Name 'Allow-TCP-Internet-VNET1-3389' -Priority 500 -Action 'Allow' -Rule $FWRule1
Add-AzFirewallPolicyRuleCollection -FirewallPolicy $Fwpolicy -NetworkRuleCollection $FWRuleCollection

$FWRule2 = New-AzFirewallNatRule -Name 'DNAT-TCP-PublicIP-VM1-3389' -Protocol 'TCP' -SourceAddress '*' -DestinationAddress $FWpip.IpAddress -DestinationPort 3389
$FWDNATRuleCollection = New-AzFirewallPolicyNatRuleCollection -Name 'DNAT-TCP-PublicIP-VM1-3389' -Priority 500 -Actiontype 'Dnat'  -Rule $FWRule2
Add-AzFirewallPolicyNatRuleCollection -FirewallPolicy $Fwpolicy -NatRuleCollection $FWDNATRuleCollection

#--------------------------------------
# VNET peering
#--------------------------------------
Add-AzVirtualNetworkPeering -Name 'vnet2-spoke' -VirtualNetwork $VNET1 -RemoteVirtualNetworkId $VNET2.Id -AllowForwardedTraffic -AllowGatewayTransit
Add-AzVirtualNetworkPeering -Name 'vnet1-hub' -VirtualNetwork $VNET2 -RemoteVirtualNetworkId $VNET1.Id -AllowForwardedTraffic 
#--------------------------------------
# Create VMs
$cred = Get-Credential -Message "Enter the username and password for the VMs."

# Create VM1 in VNET1
$VM1 = New-AzVM -Name 'vm1' -ResourceGroupName $RG -Location $Location -VirtualNetworkName $VNET1.Name -SubnetName 'subnet1' -Credential $cred
# Create VM2 in VNET2
$VM2 = New-AzVM -Name 'vm2' -ResourceGroupName $RG -Location $Location -VirtualNetworkName $VNET2.Name -SubnetName 'subnet2' -Credential $cred  

