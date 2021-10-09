param nsgName string
param location string = resourceGroup().location
param rules array

resource nsg 'Microsoft.Network/networkSecurityGroups@2021-02-01' = {
  name: nsgName
  location: location
  properties: {
    securityRules: rules
  }
}

output nsgId string = nsg.id
output nsgLocation string = nsg.location
