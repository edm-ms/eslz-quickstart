param roleId string
param principalId string
param storageAccountName string
param fileSystemName string
param synapseName string

var assignment = guid('${resourceGroup().id}/${roleId}/Synapse-${synapseName}')

resource storageRole 'Microsoft.Storage/storageAccounts/blobServices/containers/providers/roleAssignments@2018-09-01-preview' = {
  name: '${storageAccountName}/default/${fileSystemName}/Microsoft.Authorization/${assignment}'
  location: resourceGroup().location

  properties: {
    roleDefinitionId: resourceId('Microsoft.Authorization/roleDefinitions', roleId)
    principalId: principalId
    principalType: 'ServicePrincipal'
  }
}
