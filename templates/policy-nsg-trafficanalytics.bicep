targetScope = 'managementGroup'

param assignmentName string = 'EUS-NSG-FlowLogs'
param definitionId string = '/providers/Microsoft.Authorization/policyDefinitions/5e1cd26a-5090-4fdb-9d6a-84a90335e22d'
param description string = 'Enable NSG Flow Logs in East US'
param noncompliance string = 'Enable NSG FLow Logs'
param location string = 'eastus'
param lawResourceId string = '<>'
param lawGuid string = '<>'
param storageId string = '<>'
param networkWatcherRg string = 'NetworkWatcherRG'

module nsgpolicy 'modules/policy-assign.bicep' = {
  name: 'nsgflow'
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: definitionId
    policyDescription: description
    nonComplianceMessage: noncompliance
    location: location
    policyParameters: {
      timeInterval: {
        value: '10'
      }
      nsgRegion: {
        value: location
      }
      storageId: {
        value: storageId
      }
      workspaceRegion: {
        value: location
      }
      workspaceId: {
        value: lawGuid
      }
      workspaceResourceId: {
        value: lawResourceId
      }
      networkWatcherRG: {
        value: networkWatcherRg
      }
      networkWatcherName: {
        value: 'NetworkWatcher_${location}'
      }
    }
  }
}

module assignNetRole 'modules/role-assign-managementgroup.bicep' = {
  name: 'assign-contributor'
  params: {
    assignmentName: assignmentName
    principalId: nsgpolicy.outputs.policyIdentity
    principalType: 'ServicePrincipal'
    roleId: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  }
}
