targetScope                           = 'managementGroup'

param dnsResourceGroupName string     = '<>'
param networkSubId string             = '<>'
param managementGroupName string      = 'prod'
param time string                     = utcNow()

var dnsZoneParameters                 = json(loadTextContent('parameters/private-dns.json'))
var privateDNSPolicy                  = json(loadTextContent('policy/policy-deny-privatelinkdns.json'))
var location                          = deployment().location

module dnsResourceGroup 'modules/resource-group.bicep' = {
  scope: subscription(networkSubId)
  name: 'PrivateDNS-ResourceGroup-${time}'
  params: {
    location: location
    resourceGroupName: dnsResourceGroupName 
  }
}

module denyPrivateDns 'modules/policy-definition.bicep' = {
  name: 'create-denyPrivateDNS-policy'
  params: {
    managementGroupName: managementGroupName
    policyDescription: privateDNSPolicy.Description
    policyDisplayName: privateDNSPolicy.DisplayName
    policyName: privateDNSPolicy.Name
    policyParameters: privateDNSPolicy.parameters
    policyRule: privateDNSPolicy.policyRule
    mode: privateDNSPolicy.mode
  }
}

module delayForDnsPolicy 'modules/delay.bicep' = {
  name: 'delay-PrivateDNS'
}
module assignDenyDns 'modules/policy-assign.bicep' = {
  name: 'assign-deny-PrivateDNS'
  dependsOn: [
    delayForDnsPolicy
  ]
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: privateDNSPolicy.Name
    policyDefinitionId: denyPrivateDns.outputs.policyId
    policyDescription: privateDNSPolicy.Description
    exclusions: [
      '/providers/Microsoft.Management/managementGroups/${managementGroupName}-connectivity'
    ]
  }
}

module privateDnsZones 'modules/private-dns.bicep' = [for i in range(0, length(dnsZoneParameters)): {
  scope: resourceGroup(networkSubId, dnsResourceGroupName)
  name: 'DNS-Zone-${dnsZoneParameters[i].resource}'
  params: {
    dnsZone: dnsZoneParameters[i].zoneName
  }
  dependsOn: [
    dnsResourceGroup
  ]
}]

module dnsPolicy 'modules/policy-privatelink-dns.bicep' = [for i in range(0, length(dnsZoneParameters)): {
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

module assignRole 'modules/role-assign-managementgroup.bicep' = {
  name: 'assign-role-NetworkContributor'
  dependsOn: [
    delayForAssignment
  ]
  params: {
    assignmentName: 'Policy-PrivateDNS'
    principalId: assignInitiative.outputs.policyIdentity
    roleId: '4d97b98b-1d4f-4787-a291-c67834d212e7'
    principalType: 'ServicePrincipal'
  }
}
