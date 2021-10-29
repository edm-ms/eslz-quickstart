targetScope                   = 'managementGroup'
param time string             = utcNow()
param initiativeName string   = 'Allowed Regions'
param assignmentName string   = 'Allowed-Regions'
param location string         = 'eastus'
param nonCompliance string    = 'Allowed Regions: East US, East US 2, West US, West US 2, Central US'
param regions array           = json(loadTextContent('parameters/allowed-regions.json'))

var policyDeployment          = '${assignmentName}-${guid(time)}'
var initiativeData            = json(loadTextContent('policy/initiative-allowed-regions.json'))

module regionsInitiative 'modules/policy-initiative.bicep' = {
  name: 'regions-${time}'
  params: {
    description: initiativeData.Properties.Description
    displayName: initiativeData.Properties.DisplayName
    initiativeName: initiativeName
    parameters: initiativeData.Properties.Parameters
    policyDefinitions: initiativeData.Properties.PolicyDefinitions
  }
}

module waitForPolicy 'modules/delay.bicep' = {
  name: 'delayForPolicy'
}
module policy 'modules/policy-assign-systemidentity.bicep' = {
  name: policyDeployment
  dependsOn: [
    waitForPolicy
  ]
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: regionsInitiative.outputs.policyInitiativeId
    policyDescription: initiativeData.Properties.Description
    location: location
    policyDisplayName: initiativeData.Properties.DisplayName
    nonComplianceMessage: nonCompliance
    policyParameters: {
      regions: {
       value: regions
     }
    }
  }
}
