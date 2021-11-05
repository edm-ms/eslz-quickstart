targetScope = 'managementGroup'

param peerPolicy object         = json(loadTextContent('policy/policy-vnet-peering.json'))

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
