targetScope                     = 'managementGroup'

param nsgLocation string        = 'EastUS'
param storageId string          = '<>'
param lawLocation string        = 'EastUS'
param lawGuid string            = '<>'
param lawResourceId string      = '<>'
param networkWatcherRg string   = 'NetworkWatcherRG'

var definitionId = '/providers/Microsoft.Authorization/policyDefinitions/5e1cd26a-5090-4fdb-9d6a-84a90335e22d'
var noncompliance = '${description} - ${nsgLocation}'
var nsgNameFix = toLower(replace(nsgLocation, ' ', ''))
var shortRegion = replace(replace(replace(replace(replace(nsgNameFix, 'east', 'e'), 'west', 'w'), 'north', 'n'), 'south', 's'), 'central', 'c')
var region = toUpper(shortRegion)
var assignmentName = '${region}-NSG-Flow'
var description = '${toUpper(nsgLocation)} - Enable NSG FLow Logs'

module nsgpolicy 'modules/policy-assign-systemidentity.bicep' = {
  name: 'nsgflow'
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: definitionId
    policyDescription: description
    policyDisplayName: description
    nonComplianceMessage: noncompliance
    location: nsgLocation
    policyParameters: {
      timeInterval: {
        value: '10'
      }
      nsgRegion: {
        value: nsgLocation
      }
      storageId: {
        value: storageId
      }
      workspaceRegion: {
        value: lawLocation
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
        value: 'NetworkWatcher_${nsgLocation}'
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
