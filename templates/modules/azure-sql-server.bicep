param sqlServerName string
param location string = resourceGroup().location

var sqlAdminGroupName = 'Azure-SQL-DBA'
var sqlAdminGroupObjectId = 'ed6e72c7-3fd2-4629-af4c-4672fe306a24'

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
