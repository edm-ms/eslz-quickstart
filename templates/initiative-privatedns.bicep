targetScope = 'managementGroup'

param location string = deployment().location
param resourceGroupName string = 'rg-canary-eus-privatedns'
param managementGroupName string = 'canary'
param time string = utcNow()
param networkSubId string = 'a3367904-e681-41a9-bc4a-f7a4e372d380'

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
    resource: 'AKS-${location}'
    zoneName: 'privatelink.${location}.azmk8s.io'
    groupId: 'tbd'
  }
  {
    resource: 'AppService'
    zoneName: 'privatelink.azurewebsites.net'
    groupId: 'sites'
  }
  {
    resource: 'Batch-${location}'
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

resource customDnsPolicy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = [for i in range(0, length(dnsZoneArray)): {
  name: 'DNS-Policy-${dnsZoneArray[i].resource}'
  properties: {
    description: 'Create DNS record when ${dnsZoneArray[i].resource} and private link are deployed'
    displayName: 'Create DNS record when ${dnsZoneArray[i].resource} and private link are deployed'
    policyRule: {
      'if': {
        'allOf': [
          {
            'field': 'type'
            'equals': 'Microsoft.Network/privateEndpoints'
          }
          {
            'count': {
              'field': 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].groupIds[*]'
              'where': {
                'field': 'Microsoft.Network/privateEndpoints/privateLinkServiceConnections[*].groupIds[*]'
                'equals': dnsZoneArray[i].groupId
              }
            }
            'greaterOrEquals': 1
          }
        ]
      }
      'then': {
        'effect': '[parameters(\'effect\')]'
        'details': {
          'type': 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups'
          'roleDefinitionIds': [
            '/providers/Microsoft.Authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
          ]
          'deployment': {
            'properties': {
              'mode': 'incremental'
              'template': {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                'contentVersion': '1.0.0.0'
                'parameters': {
                  'privateDnsZoneId': {
                    'type': 'string'
                  }
                  'privateEndpointName': {
                    'type': 'string'
                  }
                  'location': {
                    'type': 'string'
                  }
                }
                'resources': [
                  {
                    'name': '[concat(parameters(\'privateEndpointName\'), \'/deployedByPolicy\')]'
                    'type': 'Microsoft.Network/privateEndpoints/privateDnsZoneGroups'
                    'apiVersion': '2020-03-01'
                    'location': '[parameters(\'location\')]'
                    'properties': {
                      'privateDnsZoneConfigs': [
                        {
                          'name': '${dnsZoneArray[i].resource}-Private-DNS'
                          'properties': {
                            'privateDnsZoneId': '[parameters(\'privateDnsZoneId\')]'
                          }
                        }
                      ]
                    }
                  }
                ]
              }
              'parameters': {
                'privateDnsZoneId': {
                  'value': '[parameters(\'privateDnsZoneId\')]'
                }
                'privateEndpointName': {
                  'value': '[field(\'name\')]'
                }
                'location': {
                  'value': '[field(\'location\')]'
                }
              }
            }
          }
        }
      }
    }
    parameters: {
     privateDnsZoneId:{
       type: 'String'
     }
     effect: {
       type: 'String'
       allowedValues: [
         'DeployIfNotExists'
         'Disabled'
       ]
       defaultValue: 'DeployIfNotExists'
     }
    }
  }
}]

resource customDnsInitiative 'Microsoft.Authorization/policySetDefinitions@2020-09-01' =  {
  name: 'Private-DNS-PaaS'
  properties: {
    displayName: 'Create DNS record for PaaS services'
    description: 'Create DNS record for PaaS services'
    parameters: {}
    policyDefinitions: [for i in range(0, length(dnsZoneArray)): {
      policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${managementGroupName}/providers/${customDnsPolicy[i].id}' 
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
