targetScope                     = 'managementGroup'

param nsgLocation string        = 'EastUS'
param networkWatcherRg string   = 'NetworkWatcherRG'
param logWorkspaceId string     = '<>'
param connectivitySubId string  = '<>'
param nsgStorageRg string       = 'rg-prod-eus-nsgflowlogs'

var definitionId = '/providers/Microsoft.Authorization/policyDefinitions/5e1cd26a-5090-4fdb-9d6a-84a90335e22d'
var noncompliance = '${description} - ${nsgLocation}'
var nsgNameFix = toLower(replace(nsgLocation, ' ', ''))
var shortRegion = replace(replace(replace(replace(replace(nsgNameFix, 'east', 'e'), 'west', 'w'), 'north', 'n'), 'south', 's'), 'central', 'c')
var region = toUpper(shortRegion)
var assignmentName = '${region}-NSG-Flow'
var description = '${toUpper(nsgLocation)} - Enable NSG FLow Logs'
var workspaceSub = split(logWorkspaceId, '/')[2]
var workspaceRg = split(logWorkspaceId, '/')[4]
var workspaceName = split(logWorkspaceId, '/')[8]
var nsgStorageName = 'nsgflow${replace(take(guid(connectivitySubId, nsgStorageRg), 10), '-', '')}'

module rg 'modules/resource-group.bicep' = {
  scope: subscription(connectivitySubId)
  name: nsgStorageRg
  params: {
    location: nsgLocation
    resourceGroupName: nsgStorageRg
  }
}
module storage 'modules/storage.bicep' = {
  scope: resourceGroup(connectivitySubId, nsgStorageRg)
  dependsOn: [
    rg
  ]
  name: 'create-NSG-storage'
  params: {
    sku: 'Standard_LRS'
    storageName: nsgStorageName
  }
}


resource law 'Microsoft.OperationalInsights/workspaces@2021-06-01' existing = {
  name: workspaceName
  scope: resourceGroup(workspaceSub, workspaceRg)
}

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
        value: storage.outputs.storageId
      }
      workspaceRegion: {
        value: law.location
      }
      workspaceId: {
        value: law.properties.customerId
      }
      workspaceResourceId: {
        value: logWorkspaceId
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
