targetScope = 'managementGroup'

param policyDescription string
param policyDisplayName string
param policyName string
param managementGroupName string

var policyData = json(loadTextContent('policy/policy-tags-resourcegroup.json'))

module createPolicy 'modules/policy-definition.bicep' = {
  name: 
  params: {
    managementGroupName: managementGroupName
    policyDescription: policyData.Description
    policyDisplayName: policyData.DisplayName
    policyName: policyData.Name
    policyParameters: policyData.parameters
    policyRule: policyData.policyRule
  }
}

