targetScope = 'managementGroup'

param description string = 'This initiative deploys resource locks for defined resources'
param display string = 'Deploy resource locks for critical resources'
param name string = 'Deploy resource locks for critical resources'
param assignmentName string = 'Deploy-ResourceLocks'
param managementGroupName string
param location string = 'eastus'
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
  }
}
