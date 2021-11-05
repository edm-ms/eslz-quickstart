targetScope = 'managementGroup'

param dnsPolicy object          = json(loadTextContent('policy/policy-append-dns.json'))
param routePolicy object        = json(loadTextContent('policy/policy-attach-routetable.json'))
param nsgPolicy object          = json(loadTextContent('policy/policy-attach-nsg.json'))

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

module delay 'modules/delay.bicep' = {
  name: 'delay-for-Policy'
  dependsOn: [
    dnsAppendPolicy
    routeTableAttach
    nsgAttach
  ]
}

module networkInitiative 'modules/policy-initiative.bicep' = {
  name: 'create-network-initiative'
  dependsOn: [
    delay
  ]
  params: {
    description: 'This set of policy deploys a defined network configuration to all virtual networks in a subscription.'
    displayName: 'Subscription network configuration'
    initiativeName: 'Network-Configuration'
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
    }
    policyDefinitions: [
      {
        policyDefinitionId: dnsAppendPolicy.outputs.policyId
        parameters: {
          dns: {
            value: '[parameters(\'dns\')]'
          }
        }
      }
      {
        policyDefinitionId: routeTableAttach.outputs.policyId
        parameters: {
          routeTable: {
            value: '[parameters(\'routeTable\')]'
          }
        }
      }
      {
        policyDefinitionId: nsgAttach.outputs.policyId
        parameters: {
          nsg: {
            value: '[parameters(\'nsg\')]'
          }
        }
      }      
    ]
  }
}
