targetScope                           = 'managementGroup'

param dnsResourceGroupName string     = 'rg-prod-global-privatedns'
param networkSubId string             = '<>'
  @description('VNet to link private DNS zones')
param dnsLinkedVnetId string          = '<>'        
param location string                 = 'eastus'
param time string                     = utcNow()
param dnsZoneParameters array         = json(loadTextContent('parameters/private-dns.json'))

var privateDNSPolicy                  = json(loadTextContent('policy/policy-deny-privatelinkdns.json'))
var nonComplianceMessage              = '''Private Link DNS Zones are already created: Choose "No" for "Integrate with Private DNS zone"'''
var managementGroupName               = managementGroup().name
var dnsLinkedVnetName                 = split(dnsLinkedVnetId, '/')[8]

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
module assignDenyDns 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assign-deny-PrivateDNS'
  dependsOn: [
    delayForDnsPolicy
  ]
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: privateDNSPolicy.Name
    policyDefinitionId: denyPrivateDns.outputs.policyId
    policyDescription: privateDNSPolicy.Description
    nonComplianceMessage: nonComplianceMessage
    policyDisplayName: privateDNSPolicy.DisplayName
    location: location
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

module connectDns 'modules/dns-connection.bicep' = [for i in range(0, length(dnsZoneParameters)): {
  scope: resourceGroup(networkSubId, dnsResourceGroupName)
  name: 'DNS-Connections-${dnsZoneParameters[i].resource}'
  params: {
    vnetID: dnsLinkedVnetId
    connectionName: 'Connection-to-${dnsLinkedVnetName}'
    dnsZoneName: dnsZoneParameters[i].zoneName
  }
}]

module dnsPolicy 'modules/policy-privatelink-dns.bicep' = [for i in range(0, length(dnsZoneParameters)): {
  name: 'DNS-Policy-${dnsZoneParameters[i].resource}-${time}'
  params: {
    name: 'PrivateDNS-${dnsZoneParameters[i].resource}'
    groupId: dnsZoneParameters[i].groupId
    description: 'Create DNS record when ${dnsZoneParameters[i].resource} and private link are deployed'
  }
}]

resource customDnsInitiative 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'Private-DNS-PaaS'
  properties: {
    displayName: 'Create DNS record for PaaS services'
    description: 'Create DNS record for PaaS services'
    parameters: {}
    policyDefinitions: [for i in range(0, length(dnsZoneParameters)): {
      policyDefinitionId: dnsPolicy[i].outputs.policyId
      policyDefinitionReferenceId: '${dnsZoneParameters[i].resource}-Private-DNS'
      parameters: {
        privateDnsZoneId:{
          value: privateDnsZones[i].outputs.zoneId
        }
      }
    }]
  }
}

module delayForInitiative 'modules/delay.bicep' =  {
  name: 'pause-for-initiative'
  dependsOn: [
    customDnsInitiative
  ]
}

module assignInitiative 'modules/policy-assign-systemidentity.bicep' = {
  name: 'assign-initiative-DNS'
  dependsOn: [
    delayForInitiative
  ]
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: 'Private-DNS-PaaS'
    policyDescription: 'Create DNS record for PaaS services'
    nonComplianceMessage: nonComplianceMessage
    policyDisplayName: 'Create DNS record for PaaS services'
    policyDefinitionId: customDnsInitiative.id
    location: location
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
