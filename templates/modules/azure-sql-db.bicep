param databaseName string
param serverName string
param location string = resourceGroup().location
  @allowed([
    'S0'
    'S1'
    'S2'
    'S3'
  ])
param skuName string = 'S0'
  @allowed([
    'Standard'
    'Premium'
  ])
param skuTier string = 'Standard'

resource sqlDb 'Microsoft.Sql/servers/databases@2021-02-01-preview' = {
  parent: sqlServer
  name: databaseName
  location: location
  sku: {
    name: skuName
    tier: skuTier
  }
  properties: {
    zoneRedundant: false
    sampleName: 'AdventureWorksLT'
  }
}

resource sqlServer 'Microsoft.Sql/servers@2021-02-01-preview' existing = {
  name: serverName
}

output sqlDbResourceId string = sqlDb.id
