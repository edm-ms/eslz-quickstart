targetScope                           = 'managementGroup'

param location string                 = deployment().location
param resourceGroupName string        = 'rg-canary-eus-privatedns'
param managementGroupName string      = 'canary'
param time string                     = utcNow()
param networkSubId string             = 'a3367904-e681-41a9-bc4a-f7a4e372d380'

var dnsZoneParameters                 = json(loadTextContent('parameters/private-dns.json'))

module rg 'modules/resource-group.bicep' = {
  scope: subscription(networkSubId)
  name: 'PrivateDNS-ResourceGroup-${time}'
  params: {
    location: location
    resourceGroupName: resourceGroupName 
  }
}

module privateDnsZones 'modules/private-dns.bicep' = [for i in range(0, length(dnsZoneParameters)): {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'DNS-Zone-${dnsZoneParameters[i].resource}'
  params: {
    dnsZone: dnsZoneParameters[i].zoneName
  }
  dependsOn: [
    rg
  ]
}]

module dnsPolicy 'modules/pl-dns-policy.bicep' = [for i in range(0, length(dnsZoneParameters)): {
  name: 'DNS-Policy-${dnsZoneParameters[i].resource}-${time}'
  params: {
    name: dnsZoneParameters[i].resource
    groupId: dnsZoneParameters[i].groupId
    description: 'Create DNS record when ${dnsZoneParameters[i].resource} and private link are deployed'
  }
}]

resource customDnsInitiative 'Microsoft.Authorization/policySetDefinitions@2020-09-01' =  {
  name: 'Private-DNS-PaaS'
  properties: {
    displayName: 'Create DNS record for PaaS services'
    description: 'Create DNS record for PaaS services'
    parameters: {}
    policyDefinitions: [for i in range(0, length(dnsZoneParameters)): {
      policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${dnsPolicy[i].outputs.policyId}' 
      policyDefinitionReferenceId: '${dnsZoneParameters[i].resource}-Private-DNS'
      parameters: {
        privateDnsZoneId:{
          value: privateDnsZones[i].outputs.zoneId
        }
      }
    }]
  }
}

module delayForInitiative 'modules/delay.bicep' = {
  name: 'pause-for-initiative'
  dependsOn: [
    customDnsInitiative
  ]
}

module assignInitiative 'modules/policy-assign.bicep' = {
  name: 'assign-initiative-DNS'
  dependsOn: [
    delayForInitiative
  ]
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: 'Private-DNS-PaaS'
    policyDescription: 'Create DNS record for PaaS services'
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${customDnsInitiative.id}'
  }
}

module delayForAssignment 'modules/delay.bicep' = {
  name: 'pause-for-assignment'
  dependsOn: [
    assignInitiative
  ]
}

module assignRole 'modules/role-assign.bicep' = {
  name: 'assign-role-NetworkContributor'
  dependsOn: [
    delayForAssignment
  ]
  params: {
    assignmentName: 'Policy-PrivateDNS'
    principalId: assignInitiative.outputs.policyIdentity
    roleId: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  }
}
