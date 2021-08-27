targetScope                          = 'managementGroup'
param time string                    = utcNow()
param initiativeDescription string   = 'Production naming convention for resources'
param initiativeName string          = 'Prod-Naming'
param mgtGroupName string            = 'prod'

var policyDeployment                 = '${initiativeName}-${guid(time)}'
var customPolicies                   = [
                                      json(loadTextContent('policy/policy-naming-prod-privatelink.json'))
                                      json(loadTextContent('policy/policy-naming-prod-vnet.json'))
                                      json(loadTextContent('policy/policy-naming-prod-rg.json'))
                                      json(loadTextContent('policy/policy-naming-prod-sqldb.json'))
                                      json(loadTextContent('policy/policy-naming-prod-sqlserver.json'))
                                      json(loadTextContent('policy/policy-naming-prod-keyvault.json'))
                                      json(loadTextContent('policy/policy-naming-prod-nsg.json'))
                                      json(loadTextContent('policy/policy-naming-prod-routetable.json'))
                                      json(loadTextContent('policy/policy-naming-prod-publicip.json'))
]

module namingPolicy 'modules/policy-definition.bicep' = [for policy in customPolicies: {
  name: policy.policyName
  params: {
    managementGroupName: mgtGroupName
    mode: policy.mode
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
