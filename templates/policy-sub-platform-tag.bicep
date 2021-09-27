targetScope = 'managementGroup'

param policyId string = '/providers/Microsoft.Authorization/policyDefinitions/61a4d60b-7326-440e-8051-9f94394d4dd1'
param location string = 'eastus'
param description string = 'Platform subscription tag'
param assignmentName string = 'Platform-Tag'
param nonCompliance string = 'Subscription purpose should be defined'
param tagName string = 'Subscription Type'
param tagValue string = 'Platform'

var uaiName = 'uai-prod-global-tags'
var uaiRg = 'rg-prod-global-policyidentity'
var uaiSubId = 'ab55de59-2568-431b-98a5-bd04f17033ff'

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' existing = {
  name: uaiName
  scope: resourceGroup(uaiSubId, uaiRg)
}

module policyAssign 'modules/policy-assign-managed.bicep' = {
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
