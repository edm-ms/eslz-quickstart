targetScope = 'managementGroup'

param roleIds array = [
  '/providers/Microsoft.Authorization/roleDefinitions/f9e39ccf-c9a1-437b-90da-b7b5497b514a'
]

var lockValues = json(loadTextContent('parameters/resource-locks.json'))

module locks 'modules/policy-resourcelock.bicep' = [for i in range(0, length(lockValues)): {
  name: 'lock-${lockValues[i].resource}'
  params: {
    resourceType: lockValues[i].resourceType
    resourceName: lockValues[i].resource
    roleIds: roleIds
  }
}]
