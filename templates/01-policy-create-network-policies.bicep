targetScope = 'managementGroup'

var dnsPolicy           = json(loadTextContent('policy/policy-append-dns.json'))
var routePolicy         = json(loadTextContent('policy/policy-attach-routetable.json'))
var nsgPolicy           = json(loadTextContent('policy/policy-attach-nsg.json'))
var peerPolicy          = json(loadTextContent('policy/policy-vnet-peering.json'))

module dnsAppendPolicy 'modules/policy-definition.bicep' = {
  name: 'create-DNSAppend-Policy'
  params: {
    policyDescription: dnsPolicy.Description
    policyDisplayName: dnsPolicy.DisplayName
    policyName: dnsPolicy.Name
    policyParameters: dnsPolicy.parameters
    policyRule: dnsPolicy.policyRule
    mode: dnsPolicy.mode
  }
}

module routeTableAttach 'modules/policy-definition.bicep' = {
  name: 'create-RouteTableAttach-policy'
  params: {
    policyDescription: routePolicy.Description
    policyDisplayName: routePolicy.DisplayName
    policyName: routePolicy.Name
    policyParameters: routePolicy.parameters
    policyRule: routePolicy.policyRule
    mode: routePolicy.mode
  }
}

module nsgAttach 'modules/policy-definition.bicep' = {
  name: 'create-NSGAttach-policy'
  params: {
    policyDescription: nsgPolicy.Description
    policyDisplayName: nsgPolicy.DisplayName
    policyName: nsgPolicy.Name
    policyParameters: nsgPolicy.parameters
    policyRule: nsgPolicy.policyRule
    mode: nsgPolicy.mode
  }
}

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

module networkInitiative 'modules/policy-initiative.bicep' = {
  name: 'create-network-initiative'
  params: {
    description: 'Subscription network configuration'
    displayName: 'Subscription network configuration'
    initiativeName: 'Subscription network configuration'
    parameters: {
      dns: {
        type: 'array'
      }
      routeTable: {
        type: 'object'
      }
      nsg: {
        type: 'object'
      }
      location: { 
        type: 'string'
      }
      transitVnetId: {
        type: 'string'
      }
    }
    policyDefinitions: [
      dnsAppendPolicy.outputs.policyId
      routeTableAttach.outputs.policyId
      nsgAttach.outputs.policyId
      vnetPeering.outputs.policyId
    ]
  }
}
