# Azure Storage Solutions Lab

## Objective
Work with different Azure storage types and secure them.

## Tasks
1. Create/manage Blob, File, Table, Queue storage accounts.
2. Configure lifecycle policies.
3. Apply Shared Access Signatures (SAS) and encryption.

## Skills Covered
- Azure Storage
- Data Protection
- Automation

## Scripts
- 

## Steps Completed
4. Create storage account with Standard LRS availability 
```cli
az storage account create --name 'project04storacc' -g Project04-rg -l uksouth --sku standard_lrs
```
5. Create Blob storage account with Standard LRS availability 
```cli
az storage account create --name 'project04blobstoracc' -g Project04-rg -l uksouth --kind BlobStorage --sku standard_lrs --access-tier Hot 
```
> for different storage account type change the kind to the required type.
6. Create json file called archive rule as below
``` json
{
  "rules": [
    {
      "enabled": true,
      "name": "archive-rule",
      "type": "Lifecycle",
      "definition": {
        "filters": {
          "blobTypes": ["blockBlob"]
        },
        "actions": {
          "baseBlob": {
            "tierToArchive": {
              "daysAfterModificationGreaterThan": 30
            },
            "delete": {
              "daysAfterModificationGreaterThan": 90
            }
          }
        }
      }
    }
  ]
}
```

7. Run command to apply lifecycle rule
``` cli
az storage account management-policy create --account-name project04blobstoracc --r
esource-group project04-rg --policy archive-rules.json
``` 
8. Create Shared Access Security (SAS)
```cli
az storage account generate-sas \
--account-key 00000000 \
--account-name project04blobstoracc 
--expiry 2026-01-09 \
--https-only \
--permissions acuw \ 
--resource-types co \ 
--services b 
``` 

> acuw → Add, Create, Update, Write (check if all are required)
> co → Container & Object
> b → Blob service

> the output of this will be your SAS key, note it now. It will not be displayed again

9. Validate SAS
```cli
az storage blob list \
  --container-name mycontainer \
  --account-name project04blobstoracc \
  --sas-token "<paste SAS token here>"
```


