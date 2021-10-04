targetScope = 'managementGroup'

param managementGroupName string

var policy = json(loadTextContent('policy/policy-attach-routetable.json'))

module createPolicy 'modules/policy-definition.bicep' = {
  name: 'createRouteAttach'
  params: {
    managementGroupName: managementGroupName
    policyDescription: policy.Description
    policyDisplayName: policy.DisplayName
    policyName: policy.Name
    policyParameters: policy.parameters
    policyRule: policy.policyRule
  }
}
