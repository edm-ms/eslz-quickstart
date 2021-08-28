targetScope                          = 'managementGroup'
param time string                    = utcNow()
param initiativeDescription string   = 'Production naming convention for resources'
param initiativeName string          = 'Prod-Naming'
param managementGroupName string     = 'canary'

var policyDeployment                 = '${initiativeName}-${guid(time)}'
var namingStandard                   =  json(loadTextContent('parameters/prod-naming.json'))

module namingPolicies 'modules/policy-naming.bicep' = [for i in range(0,length(namingStandard)): {
  name: replace(namingStandard[i].resource, ' ', '')
  params: {
    policyName: 'Name-${replace(namingStandard[i].resource, ' ', '')}'
    description: 'Naming format for ${namingStandard[i].resource}'
    nameMatch: namingStandard[i].nameFormat
    resourceType: namingStandard[i].resourceType
  }
}]

module initiativeDelay 'modules/delay.bicep' = {
  name: 'delay-for-initiative'
  dependsOn: [
    namingPolicies
  ]
}

resource namingInitiative 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: initiativeName
  dependsOn: [
    initiativeDelay
  ]
  properties: {
    description: initiativeDescription
    displayName: initiativeDescription
    policyDefinitions: [for i in range(0, length(namingStandard)): {
      policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${namingPolicies[i].outputs.policyId}'
    }]
  }
}

module assignDelay 'modules/delay.bicep' = {
  name: 'delay-for-role'
  dependsOn: [
    namingInitiative
  ]
}

module assignInitiative 'modules/policy-assign.bicep' = {
  name: policyDeployment
  dependsOn: [
    assignDelay
  ]
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: initiativeName
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${namingInitiative.id}'
    policyDescription: initiativeDescription
  }
}
