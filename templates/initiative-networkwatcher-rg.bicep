targetScope                       = 'managementGroup'

param location string             = 'eastus'
param description string          = 'Create Network Watcher resource group and deploy Network Watcher'
param displayName string          = 'Create Network Watcher resource group and deploy Network Watcher'
param initiativeName string       = 'Create Network Watcher resource group and deploy Network Watcher'
param assignmentName string       = 'Deploy-NetworkWatcher'
param managementGroupName string

var tags                          = json(loadTextContent('parameters/networkwatcher-tags.json'))

module networkWatcherRg 'modules/policy-networkwatcher-rg.bicep' = {
  name: 'CreateNetworkWatcherRgPolicy'
  params: {
    location: location
    tags: tags
  }
}

module delay 'modules/delay.bicep' = {
  name: 'delay'
  dependsOn: [
    networkWatcherRg
  ]
}

module createInitiative 'modules/policy-initiative.bicep' = {
  name: 'CreateNetworkInitiative'
  dependsOn: [
    delay
  ]
  params: {
    description: description
    displayName: displayName
    initiativeName: initiativeName
    managementGroupName: managementGroupName
    parameters: {}
    policyDefinitions: [
      {
        policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${networkWatcherRg.outputs.policyId}'
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a9b99dd8-06c5-4317-8629-9d86a3c6e7d9'
      }
    ]
  }
}

module delaytwo 'modules/delay.bicep' = {
  name: 'delaytwo'
  dependsOn: [
    createInitiative
  ]
}

module assignInitiative 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assignNetWatchInitiative'
  dependsOn: [
    delaytwo
  ]
  params: {
    location: location
    nonComplianceMessage: 'Deploy Network Watcher'
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: createInitiative.outputs.policyInitiativeId
    policyDescription: description
  }
}

module assignRole 'modules/role-assign-managementgroup.bicep' = {
  name: 'assignRole'
  params: {
    assignmentName: assignmentName
    principalId: assignInitiative.outputs.policyIdentity
    principalType: 'ServicePrincipal'
    roleId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
}
