targetScope = 'managementGroup'

param description string = 'This initiative deploys resource locks for defined resource types'
param display string = 'Deploy resource locks for critical resources'
param name string = 'Deploy resource locks for critical resources'
param assignmentName string = 'Deploy-ResourceLocks'
param managementGroupName string = 'contoso-platform'
param location string = 'eastus'
param roleIds array = [
  '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
]

var lockValues = json(loadTextContent('parameters/resource-locks.json'))

module locks 'modules/policy-resourcelock.bicep' = [for i in range(0, length(lockValues)): {
  name: replace(lockValues[i].resourceType, '/', '.')
  params: {
    resourceType: lockValues[i].resourceType
    resourceName: lockValues[i].resource
    roleIds: roleIds
    managementGroup: managementGroupName
  }
}]

module createInitiative 'modules/policy-initiative.bicep' = {
  name: 'initiative'
  params: {
    description: description
    displayName: display
    initiativeName: name
    managementGroupName: managementGroupName
    parameters: {}
    policyDefinitions: [for i in range(0, length(lockValues)): {
     policyDefinitionId: locks[i].outputs.policyIdFull
    }]
  }
}

module assignInit 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assignPolicy'
  params: {
    location: location
    nonComplianceMessage: 'Please apply resource lock'
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: createInitiative.outputs.policyInitiativeId
    policyDescription: description
    policyDisplayName: display
  }
}

module assignRole 'modules/role-assign-managementgroup.bicep' = {
  name: 'assignRole'
  params: {
    assignmentName: assignmentName
    principalId:  assignInit.outputs.policyIdentity
    principalType: 'ServicePrincipal'
    roleId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  }
}
