targetScope = 'managementGroup'

param mode string = 'All'
param description string 
param policyName string
param tags object
param location string
param resourceGroupName string 
param routes array
param routeTableName string

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
          'name': resourceGroupName
          'deploymentScope': 'subscription'
          'existenceScope': 'subscription'
          'existenceCondition': {
            'allOf': [
              {
                'field': 'name'
                'equals': resourceGroupName
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
                  'routeTableName': {
                    'type': 'string'
                  }
                }
                'variables': {
                  'routes': routes
                }
                'resources': [
                    {
                      'name': resourceGroupName
                      'type': 'Microsoft.Resources/resourceGroups'
                      'apiVersion': '2021-04-01'
                      'location': '[parameters(\'location\')]'
                      'dependsOn': []
                      'tags': tags                           
                  }
                  {
                    'type': 'Microsoft.Resources/deployments'
                    'apiVersion': '2019-10-01'
                    'name': 'eastRouteTable'
                    'resourceGroup': resourceGroupName
                    'properties': {
                      'expressionEvaluationOptions': {
                        'scope': 'inner'
                      }
                      'mode': 'Incremental'
                      'parameters': {
                        'routes': {
                          'value': '[variables(\'routes\')]'
                        }
                        'routeTableName': {
                          'value': '[parameters(\'routeTableName\')]'
                        }
                      }
                      'template': {
                        '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                        'contentVersion': '1.0.0.0'
                        'parameters': {
                          'routeTableName': {
                            'type': 'string'
                          }
                          'location': {
                            'type': 'string'
                            'defaultValue': '[resourceGroup().location]'
                          }
                          'routes': {
                            'type': 'array'
                          }
                        }
                        'functions': []
                        'resources': [
                          {
                            'type': 'Microsoft.Network/routeTables'
                            'apiVersion': '2021-02-01'
                            'name': '[parameters(\'routeTableName\')]'
                            'location': '[parameters(\'location\')]'
                            'properties': {
                              'disableBgpRoutePropagation': true
                              'routes': '[parameters(\'routes\')]'
                            }
                          }
                        ]
                      }
                    }
                    'dependsOn': [
                      resourceGroupName
                    ]
                  }
                ]
              }
              'parameters': {
                'location': {
                  'value': location
                }
                'routeTableName': {
                  'value': routeTableName
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
