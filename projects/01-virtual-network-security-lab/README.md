## Virtual Network & Security Lab

## Objective
Build a secure, segmented Azure network with multiple VNets, subnets, and firewall rules.

## Tasks
1. Create multiple VNets and subnets.
2. Configure Network Security Groups (NSGs) with inbound/outbound rules.
3. Set up Azure Firewall.
4. Enable VNet Peering.

## Skills Covered
- Azure Networking
- Security
- Firewall Rules
- VNet Peering

## Scripts
- `scripts/setup-vnet.ps1` → PowerShell script to create VNets and NSGs

# Steps Completed
1. Create resource group 'project01-rg'
2. Create vnet's called 'vnet1' with address space '10.0.0.0' and /24 subnet.Create 'vnet2' with address space '10.1.0.0' and /24 subnet.
4. Create NSG 'vnet1-nsg' and associate with vnet1 subnet
    - Create inbound nsg rule called allow_rdp
    - port 3389 and priority 1000
5. Create NSG 'vnet2-nsg' and associate with vnet2 subnet

> Create Firewall
6. Create subnet called 'azurefirewallsubnet' in vnet1 and vnet 2
7. Create firewall named 'vnet01-fw' with standard sku. create new standard firewall policy named 'fwpolicy' 
    - uncheck 'enable firewall management nic'
    - Selected 'use existing' virtual network 
    - Created a public ip 'fw-pip'
    ![Firewall](image.png)

//Create Firewall Rules
9. Navigate to 'Azure firewall policies' and open policy named 'fwpolicy'
10. create a rule collection as below
    Name: Allow-internet-to-VM's
    Rule type: Network
    Priority: 500
    Collection group: DefaultNetworkRuleCollectionGroup

    Name: Allow-RDP
    Source: IP Address
    Source: 0.0.0.0/0
    Protocol: TCP
    Dest Ports: 3389 
    Dest Type: IP Address
    Dest: 10.0.0.0/24,10.1.0.0/24

    Name: Allow-internet
    Source: IP Address
    Source: 0.0.0.0/0
    Protocol: TCP
    Dest Ports: 80
    Dest Type: IP Address
    Dest: 10.0.0.0/24,10.1.0.0/24

11. create a rule collection as below 
    Name: Allow-internet-to-VM's
    Rule type: Network
    Priority: 150
    Collection group: DefaultDNATRuleCollectionGroup

    Name: Allow-RDP
    Source: IP Address
    Source: 0.0.0.0
    Protocol: TCP
    Dest Ports: 3389 
    Dest Type: IP Address
    Dest: 10.0.0.0/24,10.1.0.0/24


//Creating Vnet peering
12. from vnet1 click 'peering' 
13. remote peering: Peering link name - vnet2-spoke,  
    allow forwarding for vnet2

    local peering: peering name - vnet1-hub,allow forwarding for vnet1

