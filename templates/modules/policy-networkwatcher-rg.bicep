targetScope = 'managementGroup'

param mode string = 'All'
param description string = 'Create Network Watcher resource group with required tags'
param policyName string = 'Create Network Watcher resource group'
param tags object
param location string

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    description: description
    displayName: description
    mode: mode
    policyRule: {
      'if': {
        'field': 'type'
        'equals': 'Microsoft.Resources/subscriptions'
      }
      'then': {
        'effect': 'DeployIfNotExists'
        'details': {
          'type': 'Microsoft.Resources/subscriptions/resourceGroups'
          'name': 'NetworkWatcherRG'
          'deploymentScope': 'subscription'
          'existenceScope': 'subscription'
          'existenceCondition': {
            'allOf': [
              {
                'field': 'name'
                'equals': 'NetworkWatcherRG'
              }
            ]
          }
          'roleDefinitionIds': [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          'deployment': {
            'location': location
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
                      'name': 'NetworkWatcherRG'
                      'type': 'Microsoft.Resources/resourceGroups'
                      'apiVersion': '2021-04-01'
                      'location': '[parameters(\'location\')]'
                      'dependsOn': []
                      'tags': tags                           
                  }
                ]
              }
              'parameters': {
                'location': {
                  'value': location
                }
              }
            }
          }
        }
      }
    }
    parameters: {}
  }
}

output policyId string = policy.id
