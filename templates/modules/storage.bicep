param name string
param location string = resourceGroup().location

resource storage 'Microsoft.Storage/storageAccounts@2021-02-01' = {
 name: name
 location: location
 properties: {
   allowBlobPublicAccess: false
   accessTier: 'Hot'
   minimumTlsVersion: 'TLS1_2'
   networkAcls: {
     defaultAction: 'Deny'
     ipRules: [
       {
         action: 'Allow'
         value: '73.102.9.215'
       }
     ]
   }
 }
 kind: 'StorageV2'
 sku: {
   name: 'Standard_LRS'
 }
}

output resourceId string = storage.id
