targetScope = 'managementGroup'

param groupId string
param name string
param description string
param mode string = 'Indexed'

resource privateLinkDnsPolicy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: name
  properties: {
    description: description
    displayName: description
    mode: mode
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
                'equals': groupId
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
                          'name': '${name}-Private-DNS'
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
}

output policyId string = privateLinkDnsPolicy.id
