targetScope                   = 'managementGroup'
param time string             = utcNow()
param policyID string         = '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
param description string      = 'Allowed Prod virtual machine SKUs'
param location string         = 'eastus'
param nonCompliance string    = 'Select a SKU from the following: Standard_Bms, Standard_Ds_v4, Standard_Es_v4, Standard_Fs_v2'
param skus array              = json(loadTextContent('parameters/allowed-vm-skus-prod.json'))

var policyDeployment          = '${assignmentName}-${guid(time)}'
var assignmentName            = 'Allowed-VM-SKU'

module policy 'modules/policy-assign-systemidentity.bicep' = {
  name: policyDeployment
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDisplayName: description
    policyDefinitionId: policyID
    policyDescription: description
    location: location
    nonComplianceMessage: nonCompliance
   policyParameters: {
    listOfAllowedSKUs: {
       value: skus
     }
   }
  }
}
