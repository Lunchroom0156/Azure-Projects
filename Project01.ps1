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