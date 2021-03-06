targetScope = 'managementGroup'

param description string        = 'This initiative deploys resource locks for defined resource types'
param display string            = 'Deploy resource locks for critical resources'
param name string               = 'Deploy-Resource-Locks'
param assignmentName string     = 'Deploy-ResourceLocks'
param location string           = 'eastus'
param lockValues array           = json(loadTextContent('parameters/resource-locks.json'))
param assignmentExclusions array = [
  
]

var roleIds             = [
  '/providers/Microsoft.Authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
]

module locks 'modules/policy-resourcelock.bicep' = [for i in range(0, length(lockValues)): {
  name: replace(lockValues[i].resourceType, '/', '.')
  params: {
    resourceType: lockValues[i].resourceType
    resourceName: lockValues[i].resource
    roleIds: roleIds
  }
}]

module createInitiative 'modules/policy-initiative.bicep' = {
  name: 'initiative'
  params: {
    description: description
    displayName: display
    initiativeName: name
    parameters: {}
    policyDefinitions: [for i in range(0, length(lockValues)): {
     policyDefinitionId: locks[i].outputs.policyId
     policyDefinitionReferenceId: locks[i].outputs.policyName
    }]
  }
}

module waitForInitiative 'modules/delay.bicep' = {
  name: 'delay-Initiative'
  dependsOn: [
    createInitiative
  ]
}

module assignInit 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assignPolicy'
  dependsOn: [
    waitForInitiative
  ]
  params: {
    location: location
    nonComplianceMessage: 'Please apply resource lock'
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: createInitiative.outputs.policyInitiativeId
    policyDescription: description
    policyDisplayName: display
    exclusions: assignmentExclusions
  }
}

module waitForAssign 'modules/delay.bicep' = {
  name: 'delay-Assignment'
  dependsOn: [
    assignInit
  ]
}

module assignRole 'modules/role-assign-managementgroup.bicep' = {
  name: 'assignRole'
  dependsOn: [
    waitForAssign
  ]
  params: {
    assignmentName: assignmentName
    principalId:  assignInit.outputs.policyIdentity
    principalType: 'ServicePrincipal'
    roleId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  }
}
