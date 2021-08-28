param roleId string
param principalObjId string
param vnetName string
param subnetName string
param subnetId string

var assignment = guid(subnetId)

resource storageRole 'Microsoft.Network/virtualNetworks/subnets/providers/roleAssignments@2018-09-01-preview' = {
  name: '${vnetName}/${subnetName}/Microsoft.Authorization/${assignment}'
  location: resourceGroup().location
  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalObjId
    scope: subnetId
    principalType: 'ServicePrincipal'
  }
}
