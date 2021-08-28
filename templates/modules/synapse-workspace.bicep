param name string
param adlsUrl string
param fileSystem string
param sqlAdminName string
@secure()
param sqlAdminPassword string

resource synapse 'Microsoft.Synapse/workspaces@2021-04-01-preview' = {
  name: name
  location: resourceGroup().location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    defaultDataLakeStorage: {
      accountUrl: adlsUrl
      filesystem: fileSystem
    }
    sqlAdministratorLogin: sqlAdminName
    sqlAdministratorLoginPassword: sqlAdminPassword
  }
}

resource synapseFirewall 'Microsoft.Synapse/workspaces/firewallRules@2021-04-01-preview' = {
  parent: synapse
  name: 'allowAll'
  properties: {
    startIpAddress: '0.0.0.0'
    endIpAddress: '255.255.255.255'
  }
}

output synapseIdentity string = synapse.identity.principalId
