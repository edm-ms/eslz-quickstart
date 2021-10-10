targetScope = 'managementGroup'

param resourceGroupName string          = 'rg-prod-eus-corpnetwork'
param managementGroupName string        = 'contoso-corp'
param topManagementGroup string         = 'contoso'
param assignmentName string             = 'EUS-Network-Config'

var routes        = json(loadTextContent('parameters/eastus-routes.json'))
var nsgs          = json(loadTextContent('parameters/eastus-nsgs.json'))
var tags          = json(loadTextContent('parameters/networkwatcher-tags.json'))
var dnsServers    = json(loadTextContent('parameters/dns-servers.json'))
var location      = 'eastus'
var description   = '${toUpper(location)} - Deploy corporate network policies'

module networkconfig 'modules/policy-network-config.bicep' = {
  name: 'create-NetworkAppend-policy'
  params: {
    description: description
    policyName: description
    resourceGroupName: resourceGroupName
    routeTables: routes
    nsgList: nsgs
    dnsServers: dnsServers
    tags: tags
    location: location
    managementGroup: topManagementGroup
    
  }
}

module waitForPolicy 'modules/delay.bicep' = {
  name: 'waitForPolicy'
}

module assignPolicy 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assign-NetworkAppend-policy'
  dependsOn: [
    waitForPolicy
  ]
  params: {
    location: location
    nonComplianceMessage: 'Deploy corporate NSG, route table, and DNS'
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${networkconfig.outputs.policyId}' 
    policyDescription: description
    policyDisplayName: description
  }
}