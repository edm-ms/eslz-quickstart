targetScope                   = 'managementGroup'
param time string             = utcNow()
param initiativeName string   = 'Allowed Regions'
param assignmentName string   = 'Allowed-Regions'
param mgtGroupName string     = 'contoso'
param location string         = 'eastus'
param nonCompliance string    = 'Allowed Regions: East US, East US 2, West US, West US 2, Central US'

var policyDeployment          = '${assignmentName}-${guid(time)}'
var regions                   = json(loadTextContent('parameters/allowed-regions.json'))
var initiativeData            = json(loadTextContent('policy/initiative-allowed-regions.json'))

module regionsInitiative 'modules/policy-initiative.bicep' = {
  name: 'regions-${time}'
  params: {
    description: initiativeData.Properties.Description
    displayName: initiativeData.Properties.DisplayName
    initiativeName: initiativeName
    parameters: initiativeData.Properties.Parameters
    policyDefinitions: initiativeData.Properties.PolicyDefinitions
    managementGroupName: mgtGroupName
  }
}

module policy 'modules/policy-assign-systemidentity.bicep' = {
  name: policyDeployment
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: regionsInitiative.outputs.policyInitiativeId
    policyDescription: initiativeData.Properties.Description
    location: location
    nonComplianceMessage: nonCompliance
    policyParameters: {
      regions: {
       value: regions
     }
    }
  }
}
