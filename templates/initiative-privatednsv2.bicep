targetScope = 'managementGroup'

param location string = deployment().location
param resourceGroupName string = 'rg-canary-eus-privatedns'
param managementGroupName string = 'canary'
param time string = utcNow()
param networkSubId string = 'a3367904-e681-41a9-bc4a-f7a4e372d380'

var dnsZoneParameters = json(loadTextContent('parameters/private-dns.json'))

var dnsZoneArray = [
  {
    resource: 'ACR'
    zoneName: 'privatelink.azurecr.io'
    groupId: 'registry'
  }
  {
    resource: 'ADLS'
    zoneName: 'privatelink.dfs.core.windows.net'
    groupId: 'dfs'
  }
  {
    resource: 'AKS-${toUpper(location)}'
    zoneName: 'privatelink.${location}.azmk8s.io'
    groupId: 'tbd'
  }
  {
    resource: 'AppService'
    zoneName: 'privatelink.azurewebsites.net'
    groupId: 'sites'
  }
  {
    resource: 'Batch-${toUpper(location)}'
    zoneName: 'privatelink.${location}.batch.azure.com'
    groupId: 'tbd2'
  }
  {
    resource: 'Blob'
    zoneName: 'privatelink.blob.core.windows.net'
    groupId: 'blob'
  }
  {
    resource: 'Cosmos'
    zoneName: 'privatelink.documents.azure.com'
    groupId: 'sql'
  }
  {
    resource: 'File'
    zoneName: 'privatelink.file.core.windows.net'
    groupId: 'file'
  }
  {
    resource: 'FileSync'
    zoneName: 'privatelink.afs.azure.net'
    groupId: 'afs'
  }
  {
    resource: 'KeyVault'
    zoneName: 'privatelink.vaultcore.azure.net'
    groupId: 'vault'
  }
  {
    resource: 'MySQL'
    zoneName: 'privatelink.mysql.database.azure.com'
    groupId: 'mysqlServer'
  }
  {
    resource: 'PostgreSQL'
    zoneName: 'privatelink.postgres.database.azure.com'
    groupId: 'postgresqlServer'
  }
  {
    resource: 'SQL'
    zoneName: 'privatelink.database.windows.net'
    groupId: 'SQLServer'
  }
  {
    resource: 'Synapse'
    zoneName: 'privatelink.sql.azuresynapse.net'
    groupId: 'Dev'
  }
]

module rg 'modules/resource-group.bicep' = {
  scope: subscription(networkSubId)
  name: 'PrivateDNS-ResourceGroup-${time}'
  params: {
    location: location
    resourceGroupName: resourceGroupName 
  }
}

module privateDnsZones 'modules/private-dns.bicep' = [for i in range(0, length(dnsZoneArray)): {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'DNS-Zone-${dnsZoneArray[i].resource}'
  params: {
    dnsZone: dnsZoneArray[i].zoneName
  }
  dependsOn: [
    rg
  ]
}]

module dnsPolicy 'modules/pl-dns-policy.bicep' = [for i in range(0, length(dnsZoneArray)): {
  name: 'DNS-Policy-${dnsZoneArray[i].resource}-${time}'
  params: {
    name: dnsZoneArray[i].resource
    groupId: dnsZoneArray[i].groupId
    description: 'Create DNS record when ${dnsZoneArray[i].resource} and private link are deployed'
  }
}]

resource customDnsInitiative 'Microsoft.Authorization/policySetDefinitions@2020-09-01' =  {
  name: 'Private-DNS-PaaS'
  properties: {
    displayName: 'Create DNS record for PaaS services'
    description: 'Create DNS record for PaaS services'
    parameters: {}
    policyDefinitions: [for i in range(0, length(dnsZoneArray)): {
      policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${dnsPolicy[i].outputs.policyId}' 
      policyDefinitionReferenceId: '${dnsZoneArray[i].resource}-Private-DNS'
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
  name: 'assign-DNS-initiative-${time}'
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
  name: 'assign-role-${time}'
  dependsOn: [
    delayForAssignment
  ]
  params: {
    assignmentName: 'Policy-PrivateDNS'
    principalId: assignInitiative.outputs.policyIdentity
    roleId: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  }
}
