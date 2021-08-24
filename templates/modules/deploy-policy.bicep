targetScope = 'managementGroup'
param time string = utcNow()
param assignmentName string = 'Tag-Environment'
param policyID string = '/providers/Microsoft.Authorization/policyDefinitions/40df99da-1232-49b1-a39a-6da8d878f469'
param description string = 'Inherit a tag from the subscription if missing.'

var roles = {
  contributor: 'b24988ac-6180-42a0-ab88-20f7382dd24c'
  backupContributor: '5e467623-bb1f-42f4-a55d-6e525e11384b'
  vmContributor: '9980e02c-c2be-4d73-94e8-173b1dc7cf3c'
  tagContributor: '4a9ae827-6dc8-4573-8ac7-8239d42aa03f'
  costContributor: '434105ed-43f6-45c7-a02f-909b2ba83430'
  networkContributor: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  dnsZoneContributor: 'befefa01-2a29-4197-83a8-272ff33ce314'
  dataFactoryContributor: '673868aa-7521-48a0-acc6-0f60742d39f5'
}
var policyDeployment = 'policy-${guid(time)}'
var roleDeployment = 'role-${guid(time)}'

module policy 'policy-assign.bicep' = {
  name: policyDeployment
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: policyID
    policyDescription: description
   policyParameters: {
     tagname: {
       value: 'Environment'
     }
   }
  }
}

module role 'role-assign.bicep' = {
  name: roleDeployment
  params: {
    assignmentName: assignmentName
    principalId: policy.outputs.policyIdentity
    roleId: roles.tagContributor
  }
}
