param dnsZoneList array = [
  {
    name:   'blob'
    zoneId: 'privatelink.blob.core.windows.net'
  }
  {
    name:   'file'
    zoneId: 'privatelink.file.core.windows.net'
  }
  {
    name:   'adls'
    zoneId: 'privatelink.dfs.core.windows.net'
  }
  {
    name:   'keyVault'
    zoneId: 'privatelink.vaultcore.azure.net'
  }
  {
    name:   'acr'
    zoneId: 'privatelink.azurecr.io'
  }
  {
    name:   'sqlDb'
    zoneId: 'privatelink.database.windows.net'
  }  
  {
    name:   'mysql'
    zoneId: 'privatelink.mysql.database.azure.com'
  }
  {
    name:   'postgres'
    zoneId: 'privatelink.postgres.database.azure.com'
  }
  {
    name:   'cosmosDb'
    zoneId: 'privatelink.documents.azure.com'
  }
  {
    name:   'mongoDb'
    zoneId: 'privatelink.mongo.cosmos.azure.com'
  }
  {
    name:   'cassandra'
    zoneId: 'privatelink.cassandra.cosmos.azure.com'
  }  
  {
    name:   'webapp'
    zoneId: 'privatelink.azurewebsites.net'
  }
  {
    name:   'fileSync'
    zoneId: 'privatelink.afs.azure.net'
  }    
  {
    name:   'appConfig'
    zoneId: 'privatelink.azconfig.io'
  }   
  {
    name:   'iotDeviceService'
    zoneId: 'privatelink.azure-devices-provisioning.net'
  }     
  {
    name:   'iotHub'
    zoneId: 'privatelink.azure-devices.net'
  }       
  {
    name:   'eventHub'
    zoneId: 'privatelink.servicebus.windows.net'
  }      
  {
    name:   'aks-private-eastus'
    zoneId: 'privatelink.eastus.azmk8s.io'
  }        
  {
    name:   'batch-eastus'
    zoneId: 'privatelink.eastus.batch.azure.com'
  }       
]

resource dnsZones 'Microsoft.Network/privateDnsZones@2018-09-01' = [for dnsZone in dnsZoneList: {
  name: dnsZone.zoneId
  location: 'global'
  properties: {}
}]

output zoneIds array = [for (id, i ) in dnsZoneList: {
  name: dnsZoneList[i].name
  id: dnsZones[i].id
} ]
