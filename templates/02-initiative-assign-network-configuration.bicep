targetScope = 'managementGroup'

param resourceGroupName string  = 'rg-prod-eus-corpnetwork'
param assignmentName string     = 'EUS-Network-Config'
param location string           = 'eastus'

var managementGroupName         = managementGroup().name
var routes                      = json(loadTextContent('parameters/eastus-routes.json'))
var nsgs                        = json(loadTextContent('parameters/eastus-nsgs.json'))
var tags                        = json(loadTextContent('parameters/networkwatcher-tags.json'))
var dnsServers                  = json(loadTextContent('parameters/dns-servers.json'))
var description                 = '${toUpper(location)} - Deploy corporate network policies'
var policyName                  = '${toUpper(location)}-Network'
var nonCompliance               = 'Deploy corporate NSG, route table, and DNS settings.'

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
  }
}

module waitForPolicy 'modules/delay.bicep' = {
  name: 'waitForPolicy'
  dependsOn: [
    networkconfig
  ]
}

module assignPolicy 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assign-NetworkAppend-policy'
  dependsOn: [
    waitForPolicy
  ]
  params: {
    location: location
    nonComplianceMessage: nonCompliance
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: networkconfig.outputs.policyId
    policyDescription: description
    policyDisplayName: description
  }
}

module waitForAssignment 'modules/delay.bicep' = {
  name: 'waitForAssignment'
  dependsOn: [
    assignPolicy
  ]
}

module assignRole 'modules/role-assign-managementgroup.bicep' = {
  name: 'assignRoleforPolicy'
  dependsOn: [
    waitForAssignment
  ]
  params: {
    assignmentName: assignmentName
    principalId: assignPolicy.outputs.policyIdentity
    principalType: 'ServicePrincipal'
    roleId: '8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
  }
}
