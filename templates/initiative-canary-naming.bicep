targetScope                          = 'managementGroup'
param time string                    = utcNow()
param initiativeDescription string   = 'Non-Production naming convention for resources'
param initiativeName string          = 'Non-Prod-Naming'
param mgtGroupName string            = 'ecorp-prod'

var policyDeployment                 = '${initiativeName}-${guid(time)}'
var customPolicies                   = [
                                      json(loadTextContent('policy/policy-naming-dev-privatelink.json'))
                                      json(loadTextContent('policy/policy-naming-dev-vnet.json'))
                                      json(loadTextContent('policy/policy-naming-dev-rg.json'))
]

module namingPolicy 'modules/policy-definition.bicep' = [for policy in customPolicies: {
  name: policy.policyName
  params: {
    managementGroupName: mgtGroupName
    policyDescription: policy.policyDescription
    policyDisplayName: policy.policyDisplayName
    policyName: policy.policyName
    policyParameters: policy.parameters
    policyRule: policy.policyRule
  }
}]

resource namingInitiative 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: initiativeName
  properties: {
    description: initiativeDescription
    displayName: initiativeDescription
    policyDefinitions: [for i in range(0, length(customPolicies)): {
      policyDefinitionId: namingPolicy[i].outputs.policyId
    }]
  }
}

module assignInitiative 'modules/policy-assign.bicep' = {
  name: policyDeployment
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: initiativeName
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${mgtGroupName}/providers/${namingInitiative.id}'
    policyDescription: initiativeDescription
  }
}
