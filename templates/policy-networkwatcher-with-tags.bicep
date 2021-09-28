targetScope = 'managementGroup'

param description string = 'Deploy network watcher with tags when virtual networks are created'
param policyName string = 'Network Watcher with Tags'
param assignmentName string = 'NetworkWatcher'
param nonCompliance string = 'Deploy network watcher'
param location string = 'eastus'

var tags = json(loadTextContent('parameters/networkwatcher-tags.json'))
var roles = json(loadTextContent('parameters/contributor-roles.json'))

module networkwatcher 'modules/policy-networkwatcher.bicep' = {
  name: 'NetworkWatcher'
  params: {
    description: description
    policyName: policyName
    tags: tags
  }
}

module delay 'modules/delay.bicep' = {
  name: 'wait'
  dependsOn: [
    networkwatcher
  ]
}

module assignNetwork 'modules/policy-assign-systemidentity.bicep' = {
  name: 'DeployPolicy'
  dependsOn: [
    delay
  ]
  params: {
    location: location
    nonComplianceMessage: nonCompliance
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: assignmentName
    policyDefinitionId: networkwatcher.outputs.policyId
    policyDescription: description
  }
}

module roleAssign 'modules/role-assign-managementgroup.bicep' = {
  name: 'AssignRole'
  params: {
    assignmentName: assignmentName
    principalId: assignNetwork.outputs.policyIdentity
    principalType: 'ServicePrincipal'
    roleId: roles['Network Contributor']
  }
}
