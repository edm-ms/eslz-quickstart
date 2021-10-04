targetScope = 'managementGroup'

param mode string = 'All'
param description string 
param policyName string
param tags object
param resourceGroupName string 
param routeTables array
param nsgList array

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    description: description
    displayName: description
    mode: mode
    policyRule: {
      'if': {
        'allOf': [
          {
            'field': 'type'
            'equals': 'Microsoft.Resources/subscriptions'
          }
        ]
      }
      'then': {
        'effect': 'deployIfNotExists'
        'details': {
          'deploymentScope': 'subscription'
          'existenceScope': 'resourceGroup'
          'resourceGroupName': resourceGroupName
          'type': 'Microsoft.Network/routeTables'
          'roleDefinitionIds': [
            '/providers/microsoft.authorization/roleDefinitions/b24988ac-6180-42a0-ab88-20f7382dd24c'
          ]
          'deployment': {
            'location': 'eastus'
            'properties': {
              'mode': 'incremental'
              'template': {
                '$schema': 'https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json'
                'contentVersion': '1.0.0.0'
                'parameters': {
                  'location': {
                    'type': 'string'
                  }
                  'routeTables': {
                    'type': 'array'
                  }
                  'nsgList': {
                    'type': 'array'
                  }
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
                    'name': 'routeTables'
                    'resourceGroup': resourceGroupName
                    'properties': {
                      'expressionEvaluationOptions': {
                        'scope': 'inner'
                      }
                      'mode': 'Incremental'
                      'parameters': {
                        'routeTables': {
                          'value': '[parameters(\'routeTables\')]'
                        }
                        'nsgList': {
                          'value': '[parameters(\'nsgList\')]'
                        }
                      }
                      'template': {
                        '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                        'contentVersion': '1.0.0.0'
                        'parameters': {
                          'routeTables': {
                            'type': 'array'
                          }
                          'nsgList': {
                            'type': 'array'
                          }
                        }
                        'functions': []
                        'resources': [
                          {
                            'copy': {
                              'name': 'rt'
                              'count': '[length(parameters(\'routeTables\'))]'
                            }
                            'type': 'Microsoft.Network/routeTables'
                            'apiVersion': '2021-02-01'
                            'name': '[parameters(\'routeTables\')[copyIndex()].name]'
                            'location': '[parameters(\'routeTables\')[copyIndex()].location]'
                            'properties': {
                              'disableBgpRoutePropagation': true
                              'routes': [
                                {
                                  'name': '[parameters(\'routeTables\')[copyIndex()].routename]'
                                  'properties': {
                                    'addressPrefix': '[parameters(\'routeTables\')[copyIndex()].properties.addressPrefix]'
                                    'nextHopIpAddress': '[parameters(\'routeTables\')[copyIndex()].properties.nextHopIpAddress]'
                                    'nextHopType': '[parameters(\'routeTables\')[copyIndex()].properties.nextHopType]'
                                  }
                                }
                              ]
                            }
                          }
                          {
                            'copy': {
                              'name': 'nsgs'
                              'count': '[length(parameters(\'nsgList\'))]'
                            }
                            'type': 'Microsoft.Network/networkSecurityGroups'
                            'apiVersion': '2021-02-01'
                            'name': '[parameters(\'nsgList\')[copyIndex()].name]'
                            'location': '[parameters(\'nsgList\')[copyIndex()].location]'
                          }                          
                        ]
                        'outputs': {
                          'policyParameter': {
                            'type': 'object'
                            'value': {
                              '[reference(resourceId(\'Microsoft.Network/networkSecurityGroups\', parameters(\'nsgList\')[0].name), \'2021-02-01\', \'full\').location]': {
                                'id': '[resourceId(\'Microsoft.Network/networkSecurityGroups\', parameters(\'nsgList\')[0].name)]'
                              }
                              '[reference(resourceId(\'Microsoft.Network/networkSecurityGroups\', parameters(\'nsgList\')[1].name), \'2021-02-01\', \'full\').location]': {
                                'id': '[resourceId(\'Microsoft.Network/networkSecurityGroups\', parameters(\'nsgList\')[1].name)]'
                              }
                              'disabled': {
                                'id': ''
                              }
                            }
                          }
                        }
                      }
                    }
                    'dependsOn': [
                      resourceGroupName
                    ]
                  }
                  {
                    'type': 'Microsoft.Authorization/policyAssignments'
                    'apiVersion': '2020-09-01'
                    'dependsOn': [
                      '[resourceId(\'Microsoft.Resources/deployments\', \'routeTables\')]'
                    ]
                    'name': 'Attach-NSG-Test'
                    'identity': {
                      'type': 'SystemAssigned'
                    }
                    'location': 'eastus'
                    'properties': {
                      'description': 'Attach default NSG to subnet'
                      'displayName': 'Attach default NSG to subnet'
                      'policyDefinitionId': '/providers/Microsoft.Management/managementGroups/ecorp/providers/Microsoft.Authorization/policyDefinitions/Attach-NSG'
                      'enforcementMode': 'Default'
                      'parameters': {
                        'nsg': '[reference(resourceId(\'Microsoft.Resources/deployments\', \'routeTables\'), \'2019-10-01\').outputs.policyParameter.value]'
                      }
                      'notScopes': ''
                      'nonComplianceMessages': [
                        {
                          'message': 'Attach default NSG to subnet'
                        }
                      ]
                    }
                  }

                ]
              }
              'parameters': {
                'routeTables': {
                  'value': routeTables
                }
                'nsgList': {
                  'value': nsgList
                }
                'location': {
                  'value': 'eastus'
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
