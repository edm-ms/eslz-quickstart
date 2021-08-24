targetScope = 'managementGroup'

@description('Input will determine if the policyAssignment should be enforced or not.')
@allowed([
  'Default'
  'DoNotEnforce'
])
param policyAssignmentEnforcementMode string
param policyDefinitionId string
param policyAssignmentName string
param policyDescription string
param policyParameters object = {}
param exclusions array = []

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: policyAssignmentName
  identity: {
    type: 'SystemAssigned'
  }
  location: deployment().location
  properties: {
    description: policyDescription
    displayName: policyDescription
    policyDefinitionId: policyDefinitionId
    enforcementMode: policyAssignmentEnforcementMode
    parameters: policyParameters
    notScopes: exclusions
  }
}

output policyIdentity string = policyAssignment.identity.principalId
