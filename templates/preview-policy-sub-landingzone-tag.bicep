targetScope = 'managementGroup'

param policyId string = '/providers/Microsoft.Authorization/policyDefinitions/61a4d60b-7326-440e-8051-9f94394d4dd1'
param location string = 'eastus'
param description string = 'Landing zone subscription tag'
param assignmentName string = 'LandingZone-Tag'
param nonCompliance string = 'Subscription purpose should be defined'
param tagName string = 'Subscription Type'
param tagValue string = 'Landing Zone'
param uaiName string = ''
param uaiRg string = ''
param uaiSubId string = ''

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: uaiName
  scope: resourceGroup(uaiSubId, uaiRg)
}

module policyAssign 'modules/preview-policy-assign-managedidentity.bicep' = {
  name: assignmentName
  params: {
    identityResourceId: uai.id
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
