targetScope = 'managementGroup'

var dnsPolicy           = json(loadTextContent('policy/policy-append-dns.json'))
var routePolicy         = json(loadTextContent('policy/policy-attach-routetable.json'))
var nsgPolicy           = json(loadTextContent('policy/policy-attach-nsg.json'))

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
