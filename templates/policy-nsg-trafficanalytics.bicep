targetScope = 'managementGroup'

param nsgLocation string = 'WestUS'
param storageId string = '<>'

var lawLocation = 'EastUS'
var lawGuid = '<>'
var lawResourceId = '<>'
var definitionId = '/providers/Microsoft.Authorization/policyDefinitions/5e1cd26a-5090-4fdb-9d6a-84a90335e22d'
var networkWatcherRg = 'NetworkWatcherRG'
var noncompliance = '${description} - ${nsgLocation}'
var nsgNameFix = toLower(replace(nsgLocation, ' ', ''))
var shortRegion = replace(replace(replace(replace(replace(nsgNameFix, 'east', 'e'), 'west', 'w'), 'north', 'n'), 'south', 's'), 'central', 'c')
var region = toUpper(shortRegion)
var assignmentName = '${region}-NSG-Flow'
var description = 'Enable NSG FLow Logs - ${nsgLocation}'

module nsgpolicy 'modules/policy-assign-systemidentity.bicep' = {
  name: 'nsgflow'
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: definitionId
    policyDescription: description
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
