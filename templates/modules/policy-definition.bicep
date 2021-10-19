targetScope = 'managementGroup'

param policyName string
param policyRule object
param policyDescription string
param policyDisplayName string
param mode string = 'indexed'
param policyParameters object

resource policyDef 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    policyRule: policyRule
    policyType: 'Custom'
    mode: mode
    description: policyDescription
    displayName: policyDisplayName
    parameters: policyParameters
  }
}

output policyId string = policyDef.id
