targetScope = 'managementGroup'

param resourceGroupName string  = 'rg-prod-eus-corpnetwork'
param assignmentName string     = 'EUS-Network-Config'
param location string           = 'eastus'
param routes object             = json(loadTextContent('parameters/eastus-routes.json'))
param nsgs object               = json(loadTextContent('parameters/eastus-nsgs.json'))
param dnsServers array          = json(loadTextContent('parameters/dns-servers.json'))
param nonCompliance string      = 'Deploy corporate NSG, route table, and DNS settings.'

var managementGroupName         = managementGroup().name
var tags                        = json(loadTextContent('parameters/networkwatcher-tags.json'))
var description                 = '${toUpper(location)} - Deploy corporate network policies'
var policyName                  = '${toUpper(location)}-Network'


module networkPolicy 'modules/policy-network-configv3.bicep' = {
  name: 'create-NetworkAppend-policy'
  params: {
    description: description
    policyName: policyName
    resourceGroupName: resourceGroupName
    tags: tags
    location: location
    managementGroup: managementGroupName
  }
}

module waitForPolicy 'modules/delay.bicep' = {
  name: 'waitForPolicy'
  dependsOn: [
    networkPolicy
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
    policyDefinitionId: networkPolicy.outputs.policyId
    policyDescription: description
    policyDisplayName: description
    policyParameters: {
      routeTable: {
        value: routes
      }
      nsg: {
        value: nsgs
      }
      dnsServers: {
        value: dnsServers
      }
      location: {
        value: location
      }
    }
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
