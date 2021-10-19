targetScope = 'managementGroup'

param initiativeName string
param description string
param displayName string
param parameters object
param policyDefinitions array

resource policyInitiative 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: initiativeName
  properties: {
    description: description
    displayName: displayName
    policyType: 'Custom'
    parameters: parameters
    policyDefinitions: policyDefinitions
  }
}

output policyInitiativeId string = policyInitiative.id
