targetScope                   = 'managementGroup'
param time string             = utcNow()
param policyID string         = '/providers/Microsoft.Authorization/policyDefinitions/cccc23c7-8427-4f53-ad12-b6a63eb452b3'
param description string      = 'Allowed virtual machine size SKUs'
param location string         = 'eastus'

var policyDeployment          = '${assignmentName}-${guid(time)}'
var assignmentName            = 'Allowed-VM-SKU'
var skus                      = json(loadTextContent('parameters/allowed-vm-skus-prod.json'))

module policy 'modules/policy-assign.bicep' = {
  name: policyDeployment
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: policyID
    policyDescription: description
    location: location
   policyParameters: {
    listOfAllowedSKUs: {
       value: skus
     }
   }
  }
}
