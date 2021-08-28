param name string
param location string = resourceGroup().location
  @allowed([
    'Standard_LRS'
    'Standard_GRS'
    'Premium_LRS'
    'Premium_GRS'
  ])
param skuName string
param firewallRules array = [
  {
    action: 'Allow'
    value: '1.1.1.1'
  }
]

resource storage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
 name: name
 location: location
 properties: {
   allowBlobPublicAccess: false
   accessTier: 'Hot'
   minimumTlsVersion: 'TLS1_2'
   networkAcls: {
     defaultAction: 'Deny'
     ipRules: firewallRules
   }
 }
 kind: 'StorageV2'
 sku: {
   name: skuName
 }
}

output resourceId string = storage.id
