targetScope                       = 'managementGroup'
param time string                 = utcNow()
param assignmentName string       = 'Deny-Private-DNS'
param managementGroupName string  = 'canary'
param description string          = 'Deny the creation of private DNS'

var policyID                      = '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/Microsoft.Authorization/policyDefinitions/Deny-Private-DNS-Zones'
var policyExclusions              = [
                                    '/providers/Microsoft.Management/managementGroups/${managementGroupName}-connectivity'
                                    ]
var policyDeployment              = '${assignmentName}-${guid(time)}'

module policy 'modules/policy-assign.bicep' = {
  name: policyDeployment
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: policyID
    policyDescription: description
    exclusions: policyExclusions
    policyParameters: {
   }
  }
}
