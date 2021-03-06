targetScope = 'managementGroup'

@description('Input will determine if the policyAssignment should be enforced or not.')
@allowed([
  'Default'
  'DoNotEnforce'
])
param policyAssignmentEnforcementMode string
param policyDefinitionId string
param policyAssignmentName string
param policyDisplayName string
param policyDescription string
param policyParameters object = {}
param exclusions array = []
param nonComplianceMessage string 
param location string

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2020-09-01' = {
  name: policyAssignmentName
  identity: {
    type: 'SystemAssigned'
  }
  location: location
  properties: {
    description: policyDescription
    displayName: policyDisplayName
    policyDefinitionId: policyDefinitionId
    enforcementMode: policyAssignmentEnforcementMode
    parameters: policyParameters
    notScopes: exclusions
    nonComplianceMessages: [
      {
        message: nonComplianceMessage
      }
    ]
  }
}

output policyIdentity string = policyAssignment.identity.principalId
