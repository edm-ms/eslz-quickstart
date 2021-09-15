targetScope                     = 'subscription'
param resourceGroupName string  = 'rg-prod-<>'
param principalId string        = '<>'
param time string               = utcNow()

var roles = json(loadTextContent('parameters/contributor-roles.json'))
var roleDeployName = 'roleAssign-${time}'
var assignmentName = resourceGroupName

resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupName
  location: 'EastUs'
}

module roleAssign 'modules/role-assign.bicep' = {
  scope: rg
  name: '${roleDeployName}-0'
  params: {
    assignmentName: '${assignmentName}-0'
    principalId: principalId
    principalType: 'Group'
    roleId: roles['SQL Server Contributor']
  }
}

module roleAssign2 'modules/role-assign.bicep' = {
  scope: rg
  name: '${roleDeployName}-1'
  params: {
    assignmentName: '${assignmentName}-1'
    principalId: principalId
    principalType: 'Group'
    roleId: roles['SQL DB Contributor']
  }
}
