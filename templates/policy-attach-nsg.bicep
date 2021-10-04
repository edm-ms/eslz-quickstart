targetScope = 'managementGroup'

param managementGroupName string

var policy = json(loadTextContent('policy/policy-attach-nsg.json'))

module createPolicy 'modules/policy-definition.bicep' = {
  name: 'createNSGAttach'
  params: {
    managementGroupName: managementGroupName
    policyDescription: policy.Description
    policyDisplayName: policy.DisplayName
    policyName: policy.Name
    policyParameters: policy.parameters
    policyRule: policy.policyRule
  }
}
