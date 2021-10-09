targetScope = 'managementGroup'

param resourceGroupName string = 'rg-prod-eus-corpnetwork'
param managementGroupName string = ''

var routes        = json(loadTextContent('parameters/eastus-routes.json'))
var nsgs          = json(loadTextContent('parameters/eastus-nsgs.json'))
var tags          = json(loadTextContent('parameters/networkwatcher-tags.json'))
var location      = 'eastus'
var description   = '${toUpper(location)} - Deploy corporate network policies'

module nsgAndRoute 'modules/policy-network-config.bicep' = {
  name: 'createPolicy'
  params: {
    description: description
    routeTables: routes
    nsgList: nsgs
    policyName: description
    resourceGroupName: resourceGroupName
    tags: tags
    location: location
  }
}

module assignPolicy 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assignPolicy'
  params: {
    location: location
    nonComplianceMessage: 'Deploy corporate NSG, route table, and DNS'
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: 'EUS-Network-Config'
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${nsgAndRoute.outputs.policyId}' 
    policyDescription: description
    policyDisplayName: description
  }
}
