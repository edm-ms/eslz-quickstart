targetScope = 'managementGroup'

param resourceGroupName string  = 'rg-prod-eus-corpnetwork'
param assignmentName string     = 'EUS-Network-Config'
param location string           = 'eastus'
param transitVnetId string      = ''
param managedIdentityId string  = ''

var managementGroupName         = managementGroup().name
var routes                      = json(loadTextContent('parameters/eastus-routes.json'))
var nsgs                        = json(loadTextContent('parameters/eastus-nsgs.json'))
var tags                        = json(loadTextContent('parameters/networkwatcher-tags.json'))
var dnsServers                  = json(loadTextContent('parameters/dns-servers.json'))
var description                 = '${toUpper(location)} - Deploy corporate network policies'
var policyName                  = '${toUpper(location)}-Network'
var nonCompliance               = 'Deploy corporate NSG, route table, DNS, and VNet peering.'

module networkconfig 'modules/policy-network-configv2.bicep' = {
  name: 'create-NetworkAppend-policy'
  params: {
    description: description
    policyName: policyName
    resourceGroupName: resourceGroupName
    routeTables: routes
    nsgList: nsgs
    dnsServers: dnsServers
    tags: tags
    location: location
    managementGroup: managementGroupName
    transitVnetId: transitVnetId
  }
}

module waitForPolicy 'modules/delay.bicep' = {
  name: 'waitForPolicy'
  dependsOn: [
    networkconfig
  ]
}

module pol 'modules/policy-assign-managedidentity.bicep' = {
  name: 'uai-assignPolicy'
  dependsOn: [
    waitForPolicy
  ]
  params: {
    identityResourceId: managedIdentityId
    location: location
    nonComplianceMessage: nonCompliance
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: networkconfig.outputs.policyId
    policyDescription: description
  }
}
