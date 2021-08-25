targetScope                         = 'managementGroup'
param resourceGroupName string      = 'rg-prd-eus-privatedns'
param location string               = 'eastus'
param time string                   = utcNow()
param mgtGroupName string           = 'prod'
param initiativeDescription string  = 'Create DNS record for PaaS services'
param networkSubId string           = '<>'

var adlsDnsPolicy                   = json(loadTextContent('policy/policy-dns-adls.json'))
var blobDnsPolicy                   = json(loadTextContent('policy/policy-dns-blob.json'))
var fileDnsPolicy                   = json(loadTextContent('policy/policy-dns-file.json'))
var postgresDnsPolicy               = json(loadTextContent('policy/policy-dns-postgres.json'))
var sqlDnsPolicy                    = json(loadTextContent('policy/policy-dns-sql.json'))
var mySqlDnsPolicy                  = json(loadTextContent('policy/policy-dns-mysql.json'))

var dnsZones                        = {
                                      acr: 'privatelink.azurecr.io'
                                      adls: 'privatelink.dfs.core.windows.net'
                                      aksApi: 'privatelink.${location}.azmk8s.io'
                                      appServ: 'privatelink.azurewebsites.net'
                                      batch: 'privatelink.${location}.batch.azure.com'
                                      blob: 'privatelink.blob.core.windows.net'
                                      cosmos: 'privatelink.documents.azure.com'
                                      file: 'privatelink.file.core.windows.net'
                                      fileSync: 'privatelink.afs.azure.net'
                                      keyvault: 'privatelink.vaultcore.azure.net'
                                      mySql: 'privatelink.mysql.database.azure.com'
                                      postgres: 'privatelink.postgres.database.azure.com'
                                      sql: 'privatelink.database.windows.net'
                                      synapse: 'privatelink.sql.azuresynapse.net'
                                      }

module rg 'modules/resource-group.bicep' = {
  scope: subscription(networkSubId)
  name: 'dnsrg-${time}'
  params: {
    location: location
    resourceGroupName: resourceGroupName 
  }
}

module adlsDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'adls-${time}'
  params: {
    dnsZone: dnsZones.adls
  }
}

module blobDnsd 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'blob-${time}'
  params: {
    dnsZone: dnsZones.blob
  }
}

module fileDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'file-${time}'
  params: {
    dnsZone: dnsZones.file
  }
}

module postgresDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'postgres-${time}'
  params: {
    dnsZone: dnsZones.postgres
  }
}

module sqlDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'sql-${time}'
  params: {
    dnsZone: dnsZones.sql
  }
}

module keyVaultDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'keyVaultDNS-${time}'
  params: {
    dnsZone: dnsZones.keyvault
  }
}

module acrDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'acrDNS-${time}'
  params: {
    dnsZone: dnsZones.acr
  }
}

module appServDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'appServDNS-${time}'
  params: {
    dnsZone: dnsZones.appServ
  }
}

module synapseDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'synapseDNS-${time}'
  params: {
    dnsZone: dnsZones.synapse
  }
}

module fileSyncDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'fileSyncDNS-${time}'
  params: {
    dnsZone: dnsZones.fileSync
  }
}

module cosmosDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'cosmosDNS-${time}'
  params: {
    dnsZone: dnsZones.cosmos
  }
}

module batchDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'batchDNS-${time}'
  params: {
    dnsZone: dnsZones.batch
  }
}

module mySqlDns 'modules/private-dns.bicep' = {
  scope: resourceGroup(networkSubId, resourceGroupName)
  name: 'mySqlDNS-${time}'
  params: {
    dnsZone: dnsZones.mySql
  }
}

module adlsPolicy 'modules/policy-definition.bicep' = { 
  name: 'adlsPolicy-${time}'
  params: {
    managementGroupName: mgtGroupName
    policyDescription: adlsDnsPolicy.description
    policyDisplayName: adlsDnsPolicy.displayName
    policyName: adlsDnsPolicy.name
    policyParameters: adlsDnsPolicy.parameters
    policyRule: adlsDnsPolicy.policyRule
  }
}

module blobPolicy 'modules/policy-definition.bicep' = { 
  name: 'blobPolicy-${time}'
  params: {
    managementGroupName: mgtGroupName
    policyDescription: blobDnsPolicy.description
    policyDisplayName: blobDnsPolicy.displayName
    policyName: blobDnsPolicy.name
    policyParameters: blobDnsPolicy.parameters
    policyRule: blobDnsPolicy.policyRule
  }
}

module filePolicy 'modules/policy-definition.bicep' = { 
  name: 'filePolicy-${time}'
  params: {
    managementGroupName: mgtGroupName
    policyDescription: fileDnsPolicy.description
    policyDisplayName: fileDnsPolicy.displayName
    policyName: fileDnsPolicy.name
    policyParameters: fileDnsPolicy.parameters
    policyRule: fileDnsPolicy.policyRule
  }
}

module postgresPolicy 'modules/policy-definition.bicep' = { 
  name: 'postgresPolicy-${time}'
  params: {
    managementGroupName: mgtGroupName
    policyDescription: postgresDnsPolicy.description
    policyDisplayName: postgresDnsPolicy.displayName
    policyName: postgresDnsPolicy.name
    policyParameters: postgresDnsPolicy.parameters
    policyRule: postgresDnsPolicy.policyRule
  }
}

module sqlPolicy 'modules/policy-definition.bicep' = { 
  name: 'sqlPolicy-${time}'
  params: {
    managementGroupName: mgtGroupName
    policyDescription: sqlDnsPolicy.description
    policyDisplayName: sqlDnsPolicy.displayName
    policyName: sqlDnsPolicy.name
    policyParameters: sqlDnsPolicy.parameters
    policyRule: sqlDnsPolicy.policyRule
  }
}

module mySqlPolicy 'modules/policy-definition.bicep' = { 
  name: 'mySqlPolicy-${time}'
  params: {
    managementGroupName: mgtGroupName
    policyDescription: mySqlDnsPolicy.description
    policyDisplayName: mySqlDnsPolicy.displayName
    policyName: mySqlDnsPolicy.name
    policyParameters: mySqlDnsPolicy.parameters
    policyRule: mySqlDnsPolicy.policyRule
  }
}

resource policyInitiative 'Microsoft.Authorization/policySetDefinitions@2020-09-01' = {
  name: 'Private-DNS-PaaS'
  properties: {
    description: initiativeDescription
    displayName: initiativeDescription
    policyType: 'Custom'
    parameters: {
      adlsDnsId: {
        type: 'String'
        defaultValue: ''
      }
      blobDnsId: {
        type: 'String'
        defaultValue: ''
      }
      fileDnsId: {
        type: 'String'
        defaultValue: ''
      }
      postgresDnsId: {
        type: 'String'
        defaultValue: ''
      }
      sqlDnsId: {
        type: 'String'
        defaultValue: ''
      }
      keyVaultDnsId: {
        type: 'String'
        defaultValue: ''
      }
      acrDnsId: {
        type: 'String'
        defaultValue: ''
      }
      appServiceDnsId: {
        type: 'String'
        defaultValue: ''
      }
      synapseDnsId: {
        type: 'String'
        defaultValue: ''
      } 
      fileSyncDnsId: {
        type: 'String'
        defaultValue: ''
      } 
      cosmosDnsId: {
        type: 'String'
        defaultValue: ''
      } 
      batchDnsId: {
        type: 'String'
        defaultValue: ''
      }       
      mySqlDnsId: {
        type: 'String'
        defaultValue: ''
      }
    }
    policyDefinitions: [
      {
        policyDefinitionId: adlsPolicy.outputs.policyId
        policyDefinitionReferenceId: 'ADLS-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'adlsDnsId\')]'
          }
        }
      }
      {
        policyDefinitionId: blobPolicy.outputs.policyId
        policyDefinitionReferenceId: 'Blob-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'blobDnsId\')]'
          }
        }
      }
      {
        policyDefinitionId: filePolicy.outputs.policyId
        policyDefinitionReferenceId: 'File-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'fileDnsId\')]'
          }
        }
      }
      {
        policyDefinitionId: postgresPolicy.outputs.policyId
        policyDefinitionReferenceId: 'PostgreSql-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'postgresDnsId\')]'
          }
        }
      }
      {
        policyDefinitionId: sqlPolicy.outputs.policyId
        policyDefinitionReferenceId: 'SQL-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'sqlDnsId\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/ac673a9a-f77d-4846-b2d8-a57f8e1c01d4'
        policyDefinitionReferenceId: 'KeyVault-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'keyVaultDnsId\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/e9585a95-5b8c-4d03-b193-dc7eb5ac4c32'
        policyDefinitionReferenceId: 'ACR-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'acrDnsId\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/06695360-db88-47f6-b976-7500d4297475'
        policyDefinitionReferenceId: 'FileSync-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'fileSyncDnsId\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/1e5ed725-f16c-478b-bd4b-7bfa2f7940b9'
        policyDefinitionReferenceId: 'Synapse-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'synapseDnsId\')]'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/a63cc0bd-cda4-4178-b705-37dc439d3e0f'
        policyDefinitionReferenceId: 'Cosmos-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'cosmosDnsId\')]'
          }
          privateEndpointGroupId: {
            value: 'SQL'
          }
        }
      }
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/b318f84a-b872-429b-ac6d-a01b96814452'
        policyDefinitionReferenceId: 'AppService-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'appServiceDnsId\')]'
          }
        }
      }    
      {
        policyDefinitionId: '/providers/Microsoft.Authorization/policyDefinitions/4ec38ebc-381f-45ee-81a4-acbc4be878f8'
        policyDefinitionReferenceId: 'Batch-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'batchDnsId\')]'
          }
        }
      }     
      {
        policyDefinitionId: mySqlPolicy.outputs.policyId
        policyDefinitionReferenceId: 'mySql-Private-DNS'
        parameters: {
          privateDnsZoneId: {
            value: '[parameters(\'mySqlDnsId\')]'
          }
        }
      }                                          
    ]
  }
}

module dnsAssignPolicy 'modules/policy-assign.bicep' = {
  name: 'assignDNSPolicy-${time}'
  params: {
    policyAssignmentEnforcementMode: 'Default'
    policyAssignmentName: 'Private-DNS-PaaS'
    policyDefinitionId: '/providers/Microsoft.Management/managementGroups/${mgtGroupName}/providers/${policyInitiative.id}'
    policyDescription: initiativeDescription
    policyParameters: {
      adlsDnsId: {
        value: adlsDns.outputs.zoneId
      }
      blobDnsId: {
        value: blobDnsd.outputs.zoneId
      }
      fileDnsId: {
        value: fileDns.outputs.zoneId
      }
      postgresDnsId: {
        value: postgresDns.outputs.zoneId
      }
      sqlDnsId: {
        value: sqlDns.outputs.zoneId
      }
      keyVaultDnsId: {
        value: keyVaultDns.outputs.zoneId
      }      
      acrDnsId: {
        value: acrDns.outputs.zoneId
      }
      fileSyncDnsId: {
        value: fileSyncDns.outputs.zoneId
      }         
      cosmosDnsId: {
        value: cosmosDns.outputs.zoneId
      }
      synapseDnsId: {
        value: synapseDns.outputs.zoneId
      }
      appServiceDnsId: {
        value: appServDns.outputs.zoneId
      }
      batchDnsId: {
        value: batchDns.outputs.zoneId
      }
      mySqlDnsId: {
        value: mySqlDns.outputs.zoneId
      }
    }
  }
}

module roleAssign 'modules/role-assign.bicep' = {
  name: 'roleAssign-${time}'
  params: {
    assignmentName: 'Private-DNS-PaaS'
    principalId: dnsAssignPolicy.outputs.policyIdentity
    roleId: '4d97b98b-1d4f-4787-a291-c67834d212e7'
  }
}
