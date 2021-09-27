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
param nonComplianceMessage string 
param identityResourceId string
param location string

resource policyAssignment 'Microsoft.Authorization/policyAssignments@2021-06-01' = {
  name: policyAssignmentName
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityResourceId}': {}
    }
  }
  location: location
  properties: {
    description: policyDescription
    displayName: policyDescription
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
