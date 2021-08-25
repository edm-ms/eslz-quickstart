targetScope                     = 'managementGroup'
param time string               = utcNow()
param assignmentName string     = 'Deny-Private-DNS'
param policyID string           = '/providers/Microsoft.Management/managementGroups/prod/providers/Microsoft.Authorization/policyDefinitions/Deny-Private-DNS-Zones'
param policyExclusions array   = [
                                  '/providers/Microsoft.Management/managementGroups/prod-connectivity'
                                 ]
param description string        = 'Deny the creation of private DNS'

var policyDeployment            = '${assignmentName}-${guid(time)}'

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
