targetScope                       = 'managementGroup'

param location string             = 'eastus'
param description string          = 'Create Network Watcher resource group'
param displayName string          = 'Create Network Watcher resource group'
param assignmentName string       = 'Deploy-NetworkWatcherRG'
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

module assignPolicy 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assignPolicy'
  params: {
    location: location
    nonComplianceMessage: displayName
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${networkWatcherRg.outputs.policyId}'
    policyDescription: description
    policyDisplayName: displayName
  }
}

module assignRole 'modules/role-assign-managementgroup.bicep' = {
  name: 'assignRole'
  params: {
    assignmentName: assignmentName
    principalId: assignPolicy.outputs.policyIdentity
    principalType: 'ServicePrincipal'
    roleId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
}
