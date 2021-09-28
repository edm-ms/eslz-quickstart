targetScope = 'managementGroup'

param mode string = 'Indexed'
param description string
param policyName string
param tags object

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    description: description
    displayName: description
    mode: mode
    policyRule: {
      'if': {
        'field': 'type'
        'equals': 'Microsoft.Network/virtualNetworks'
      }
      'then': {
        'effect': 'DeployIfNotExists'
        'details': {
          'type': 'Microsoft.Network/networkWatchers'
          'resourceGroupName': 'networkWatcherRG'
          'existenceCondition': {
            'field': 'location'
            'equals': '[field(\'location\')]'
          }
          'roleDefinitionIds': [
            '/providers/microsoft.authorization/roleDefinitions/4d97b98b-1d4f-4787-a291-c67834d212e7'
          ]
          'deployment': {
            'properties': {
              'mode': 'incremental'
              'template': {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json'
                'contentVersion': '1.0.0.0'
                'parameters': {
                  'location': {
                    'type': 'string'
                  }
                }
                'resources': [
                  {
                    'apiVersion': '2016-09-01'
                    'type': 'Microsoft.Network/networkWatchers'
                    'name': '[concat(\'networkWatcher_\' parameters(\'location\'))]'
                    'location': '[parameters(\'location\')]'
                    'tags': tags
                  }
                ]
              }
              'parameters': {
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
      location:{
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

output policyId string = policy.id
