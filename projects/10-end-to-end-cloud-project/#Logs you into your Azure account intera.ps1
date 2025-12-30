#Logs you into your Azure account interactively
Login-AzAccount
# Sets the active subscription to the specified subscription name.
Set-AzContext -Subscription "SubscriptionName"
# Creates a new resource group named 'ResourceGroupName' in the 'East US 2' region.
New-AzResourceGroup -Name "ResourceGroupName" -Location "East US 2"
# Creates a new storage account named 'storageaccount' in the specified resource group and region, with geo-redundant storage.
New-AzStorageAccount -Name "storageaccount" -ResourceGroupName "ResourceGroupName" -Location "East US 2" -SkuName "Standard_GRS" -location "East US 2"
# Retrieves the access keys for the specified storage account.
Get-AzureStorageAccountKey -ResourceGroupName "ResourceGroupName" -Name "storageaccount"

#-SkuName is the primary parameter (e.g., "Standard_LRS", "Standard_GRS", "Premium_LRS").
#-SkuKind (sometimes used in newer APIs) specifies the SKU type related to the kind of storage account, such as BlobStorage.