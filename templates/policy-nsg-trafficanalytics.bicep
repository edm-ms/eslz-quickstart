targetScope = 'managementGroup'

param definitionId string = '/providers/Microsoft.Authorization/policyDefinitions/5e1cd26a-5090-4fdb-9d6a-84a90335e22d'
param location string = 'EastUS'
param lawResourceId string = '<>'
param lawGuid string = '<>'
param storageId string = '<>'
param networkWatcherRg string = 'NetworkWatcherRG'

var noncompliance = '${description} - ${location}'
var shortRegion = replace(replace(replace(replace(replace(location, 'east', 'e'), 'west', 'w'), 'north', 'n'), 'south', 's'), 'central', 'c')
var assignmentName = '${shortRegion}-NSG-Flow'
var description = 'Enable NSG FLow Logs - ${location}'

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
