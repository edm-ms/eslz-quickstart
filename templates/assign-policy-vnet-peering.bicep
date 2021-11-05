targetScope = 'managementGroup'

param assignmentName string     = 'EUS-Network-Peer'
param location string           = 'eastus'
param transitVnetId string      = ''
param managedIdentityId string  = ''
@allowed([
  'Default'
  'DoNotEnforce'
])
param policyEnforcement string  = 'Default'
param policyName string         = 'Create-VNetPeer'
param nonCompliance string      = 'Connect VNet to corporate transit network'

var description                 = '${toUpper(location)} - Create VNet peering with transit VNet'

resource vnetPeerPolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' existing = {
  name: policyName
}

module assignPolicy 'modules/policy-assign-managedidentity.bicep' = {
  name: 'assign-VNet-policy'
  params: {
    identityResourceId: managedIdentityId
    location: location
    nonComplianceMessage: nonCompliance
    policyAssignmentEnforcementMode: policyEnforcement
    policyAssignmentName: assignmentName
    policyDefinitionId: vnetPeerPolicy.id
    policyDescription: description
    policyParameters: {
      location: {
        value: location
      }
      transitVnetId: {
        value: transitVnetId
      }
    }
  }
}
