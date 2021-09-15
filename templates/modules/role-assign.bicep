param roleId string
param assignmentName string
param principalId string
@allowed([
  'User'
  'ServicePrincipal'
  'Group'
  'MSI'
])
param principalType string

resource roleAssign 'Microsoft.Authorization/roleAssignments@2020-08-01-preview' = {
  name: guid(roleId, assignmentName)
  properties: {
    principalType: principalType
    roleDefinitionId: '/providers/Microsoft.Authorization/roleDefinitions/${roleId}'
    principalId: principalId
  }
}

output roleId string = roleAssign.id
