targetScope = 'managementGroup'

param nsgIds object

module assignNSG 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assignNSG'
  params: {
    location: 'eastus'
    nonComplianceMessage: 'Attach default NSG to subnet'
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: 'Attach-NSG-Test'
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/ecorp/providers/Microsoft.Authorization/policyDefinitions/Attach-NSG'
    policyDescription: 'Attach default NSG to subnet'
    policyDisplayName: 'Attach default NSG to subnet'
    policyParameters: {
      nsg: {
        value: nsgIds
      }
    }
  }
}
