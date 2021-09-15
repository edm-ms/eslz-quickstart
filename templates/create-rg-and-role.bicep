targetScope                     = 'subscription'
param resourceGroupName string  = ''
param assignmentName string     = '<>'
param principalId string        = '<>'
param time string               = utcNow()

var roles = json(loadTextContent('parameters/contributor-roles.json'))
var roleDeployName = 'roleAssign-${time}'

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: deployment().location
}

module roleAssign 'modules/role-assign.bicep' = {
  scope: rg
  name: roleDeployName
  params: {
    assignmentName: assignmentName
    principalId: principalId
    principalType: 
    roleId: 
  }
}
