targetScope = 'managementGroup'

param policyName string
param policyRule object
param policyDescription string
param policyDisplayName string
param policyParameters object
param managementGroupName string

resource policyDef 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    policyRule: policyRule
    policyType: 'Custom'
    description: policyDescription
    displayName: policyDisplayName
    parameters: policyParameters
  }
}

output policyId string = '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${policyDef.id}'
