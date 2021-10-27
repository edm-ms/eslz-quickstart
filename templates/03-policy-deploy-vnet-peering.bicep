targetScope = 'managementGroup'

param assignmentName string     = 'EUS-Network-Peer'
param location string           = 'eastus'
param transitVnetId string      = ''
param managedIdentityId string  = ''

var peerPolicy          = json(loadTextContent('policy/policy-vnet-peering.json'))
var nonCompliance       = 'Connect VNet to corporate transit network'


module vnetPeering 'modules/policy-definition.bicep' = {
  name: 'create-vnetPeer-policy'
  params: {
    policyDescription: peerPolicy.Description
    policyDisplayName: peerPolicy.DisplayName
    policyName: peerPolicy.Name
    policyParameters: peerPolicy.parameters
    policyRule: peerPolicy.policyRule
    mode: peerPolicy.mode
  }
}

module delayForPolicy 'modules/delay.bicep' = {
  name: 'waitForPolicy'
}

module assignPolicy 'modules/policy-assign-managedidentity.bicep' = {
  name: 'assign-VNet-policy'
  dependsOn: [
    delayForPolicy
  ]
  params: {
    identityResourceId: managedIdentityId
    location: location
    nonComplianceMessage: nonCompliance
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: vnetPeering.outputs.policyId
    policyDescription: peerPolicy.Description
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
