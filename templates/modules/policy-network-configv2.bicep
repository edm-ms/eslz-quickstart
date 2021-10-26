targetScope = 'managementGroup'

param mode string = 'All'
param description string 
param policyName string
param tags object
param resourceGroupName string 
param routeTables array
param nsgList array
param location string
param transitVnetId string
param managementGroup string
param dnsServers array

var locationUpper = toUpper(location)
var locationShortName = replace(replace(replace(replace(replace(locationUpper, 'EAST', 'E'), 'WEST', 'W'), 'NORTH', 'N'), 'SOUTH', 'S'), 'CENTRAL', 'C')
var deploymentName = 'NSG-and-Route-Policy-${locationUpper}'

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
            '/providers/microsoft.authorization/roleDefinitions/8e3af657-a8ff-443c-a75c-2fe8c4bcb635'
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
                    'name': deploymentName
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
                              'routes': '[parameters(\'routeTables\')[copyIndex()].routes]'
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
                            'properties': {
                              'securityRules': '[parameters(\'nsgList\')[copyIndex()].securityRules]'
                            }
                          }                          
                        ]
                        'outputs': {
                          'nsgPolicyParam': {
                            'type': 'object'
                            'value': {
                              '[reference(resourceId(\'Microsoft.Network/networkSecurityGroups\', parameters(\'nsgList\')[0].name), \'2021-02-01\', \'full\').location]': {
                                'id': '[resourceId(\'Microsoft.Network/networkSecurityGroups\', parameters(\'nsgList\')[0].name)]'
                              }
                              'disabled': {
                                'id': ''
                              }
                            }
                          }
                          'routePolicyParam': {
                            'type': 'object'
                            'value': {
                              '[reference(resourceId(\'Microsoft.Network/routeTables\', parameters(\'routeTables\')[0].name), \'2021-02-01\', \'full\').location]': {
                                'id': '[resourceId(\'Microsoft.Network/routeTables\', parameters(\'routeTables\')[0].name)]'
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
                    'dependsOn': []
                    'name': '${locationShortName}-Network-Config'
                    'identity': {
                      'type': 'SystemAssigned'
                    }
                    'location': location
                    'properties': {
                      'description': '${locationUpper} - Subscription network configuration'
                      'displayName': '${locationUpper} - Subscription network configuration'
                      'policyDefinitionId': '/providers/Microsoft.Management/managementGroups/${managementGroup}/providers/Microsoft.Authorization/policySetDefinitions/Network-Configuration'
                      'enforcementMode': 'Default'
                      'parameters': {
                        'dns': {
                          'value': dnsServers
                        }
                        'routeTable': {
                          'value': '[reference(concat(subscription().id, \'/resourceGroups/\', \'${resourceGroupName}\', \'/providers/Microsoft.Resources/deployments/\', \'${deploymentName}\'), \'2019-10-01\').outputs.routePolicyParam.value]'
                        }
                        'nsg': {
                          'value': '[reference(concat(subscription().id, \'/resourceGroups/\', \'${resourceGroupName}\', \'/providers/Microsoft.Resources/deployments/\', \'${deploymentName}\'), \'2019-10-01\').outputs.nsgPolicyParam.value]'
                        }
                        'location': {
                          'value': location
                        }
                        'transitVnetId': {
                          'value': transitVnetId
                        }
                      }
                      'notScopes': ''
                      'nonComplianceMessages': [
                        {
                          'message': 'Append DNS settings to all VNets'
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
