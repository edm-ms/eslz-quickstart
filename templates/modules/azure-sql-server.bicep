param sqlServerName string
param location string = resourceGroup().location
param sqlAdminGroupName string 
param sqlAdminGroupObjectId string

resource sqlserver 'Microsoft.Sql/servers@2021-02-01-preview' = {
  name: sqlServerName
  location: location
  properties: {
    minimalTlsVersion: '1.2'
    administrators: {
      azureADOnlyAuthentication: true
      login: sqlAdminGroupName
      sid: sqlAdminGroupObjectId
      administratorType: 'ActiveDirectory'
      principalType: 'Group'
    }
  }
}

output sqlServerResourceId string = sqlserver.id
output sqlServerName string = sqlserver.name
