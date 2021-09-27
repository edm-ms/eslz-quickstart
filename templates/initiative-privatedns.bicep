targetScope                           = 'managementGroup'

param dnsResourceGroupName string     = 'rg-prod-global-privatedns'
param networkSubId string             = 'ab0b3a8a-1388-486d-9f00-483365edf8c4'
param dnsSubId string                 = '22633ee1-24cc-43d1-8b67-29925fa42e97'
param dnsVnetName string              = 'vnet-prod-eus-aadds'
param dnsVnetResourceGroupName string = 'rg-prod-eus-domainnetwork'
param managementGroupName string      = 'contoso'
param location string                 = 'eastus'
param policyPreview bool              = false
param time string                     = utcNow()

var dnsZoneParameters                 = json(loadTextContent('parameters/private-dns.json'))
var privateDNSPolicy                  = json(loadTextContent('policy/policy-deny-privatelinkdns.json'))
var nonComplianceMessage              = '''Private Link DNS Zones are already created: Choose "No" for "Integrate with Private DNS zone"'''

module dnsResourceGroup 'modules/resource-group.bicep' = {
  scope: subscription(networkSubId)
  name: 'PrivateDNS-ResourceGroup-${time}'
  params: {
    location: location
    resourceGroupName: dnsResourceGroupName 
  }
}

resource dnsLinkedVnet 'Microsoft.Network/virtualNetworks@2021-02-01' existing = {
  name: dnsVnetName
  scope: resourceGroup(dnsSubId, dnsVnetResourceGroupName)
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
    vnetID: dnsLinkedVnet.id
    connectionName: 'Connection-to-${dnsLinkedVnet.name}'
    dnsZoneName: dnsZoneParameters[i].zoneName
  }
}]


module dnsPolicyPreview 'modules/preview-policy-privatelink-dns.bicep' = [for i in range(0, length(dnsZoneParameters)): if (policyPreview == true) {
  name: 'DNS-Policy-${dnsZoneParameters[i].resource}-${time}'
  params: {
    name: 'PrivateDNS-${dnsZoneParameters[i].resource}'
    groupId: dnsZoneParameters[i].groupId
    description: 'Create DNS record when ${dnsZoneParameters[i].resource} and private link are deployed'
  }
}]

module dnsPolicy 'modules/policy-privatelink-dns.bicep' = [for i in range(0, length(dnsZoneParameters)): if (policyPreview == false) {
  name: 'DNS-Policy-${dnsZoneParameters[i].resource}-${time}'
  params: {
    name: 'PrivateDNS-${dnsZoneParameters[i].resource}'
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
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${customDnsInitiative.id}'
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
