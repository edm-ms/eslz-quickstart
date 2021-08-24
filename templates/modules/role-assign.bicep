targetScope = 'managementGroup'

param roleId string
param assignmentName string
param principalId string


resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(roleId, assignmentName)
  properties: {
    principalType: 'ServicePrincipal'
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${roleId}'
    principalId: principalId
  }
}
