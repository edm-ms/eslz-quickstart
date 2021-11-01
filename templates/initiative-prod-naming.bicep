targetScope                          = 'managementGroup'
param time string                    = utcNow()
param initiativeDescription string   = 'Production naming convention for resources'
param initiativeName string          = 'Prod-Naming'
param nonComplianceMessage string    = 'Required Name Format: <shortName>-prod-'
param location string                =  'eastus'
param namingStandard array           =  json(loadTextContent('parameters/prod-naming.json'))

var policyDeployment                 = '${initiativeName}-${guid(time)}'


module namingPolicies 'modules/policy-naming.bicep' = [for i in range(0,length(namingStandard)): {
  name: replace(namingStandard[i].resource, ' ', '')
  params: {
    policyName: 'Prod-Name-${replace(namingStandard[i].resource, ' ', '')}'
    description: 'Production naming format for ${namingStandard[i].resource}'
    nameMatch: namingStandard[i].nameFormat
    resourceType: namingStandard[i].resourceType
    mode: namingStandard[i].policyMode

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
      policyDefinitionId: namingPolicies[i].outputs.policyId
    }]
  }
}

module assignDelay 'modules/delay.bicep' = {
  name: 'delay-for-role'
  dependsOn: [
    namingInitiative
  ]
}

module assignInitiative 'modules/policy-assign-systemidentity.bicep' = {
  name: policyDeployment
  dependsOn: [
    assignDelay
  ]
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: initiativeName
    policyDefinitionId: namingInitiative.id
    policyDescription: initiativeDescription
    nonComplianceMessage: nonComplianceMessage
    policyDisplayName: initiativeDescription
    location: location
    exclusions: []
  }
}
