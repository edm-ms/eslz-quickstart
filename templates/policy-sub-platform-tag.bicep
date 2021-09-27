targetScope = 'managementGroup'

param policyId string = '/providers/Microsoft.Authorization/policyDefinitions/61a4d60b-7326-440e-8051-9f94394d4dd1'
param location string = 'eastus'
param description string = 'Platform subscription tag'
param assignmentName string = 'Platform-Tag'
param nonCompliance string = 'Subscription purpose should be defined'
param tagName string = 'Subscription Type'
param tagValue string = 'Platform'

module policyAssign 'modules/policy-assign-systemidentity.bicep' = {
  name: assignmentName
  params: {
    location: location
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: policyId
    policyDescription: description
    nonComplianceMessage: nonCompliance
    policyParameters: {
      tagName: {
        value: tagName
      }
      tagValue: {
        value: tagValue
      }
    }
  }
}
