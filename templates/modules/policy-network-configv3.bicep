targetScope = 'managementGroup'

param mode string = 'All'
param description string 
param policyName string
param tags object
param resourceGroupName string 
param location string
param managementGroup string

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
                  'routeTable': {
                    'type': 'object'
                  }
                  'dnsServers': {
                    'type': 'array'
                  }
                  'nsg': {
                    'type': 'object'
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
                        'routeTable': {
                          'value': '[parameters(\'routeTable\')]'
                        }
                        'nsg': {
                          'value': '[parameters(\'nsg\')]'
                        }
                      }
                      'template': {
                        '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#'
                        'contentVersion': '1.0.0.0'
                        'parameters': {
                          'routeTable': {
                            'type': 'object'
                          }
                          'nsg': {
                            'type': 'object'
                          }
                        }
                        'functions': []
                        'resources': [
                          {
                            'type': 'Microsoft.Network/routeTables'
                            'apiVersion': '2021-02-01'
                            'name': '[parameters(\'routeTable\').name]'
                            'location': '[parameters(\'routeTable\').location]'
                            'properties': {
                              'disableBgpRoutePropagation': true
                              'routes': '[parameters(\'routeTable\').routes]'
                            }
                          }
                          {
                            'type': 'Microsoft.Network/networkSecurityGroups'
                            'apiVersion': '2021-02-01'
                            'name': '[parameters(\'nsg\').name]'
                            'location': '[parameters(\'nsg\').location]'
                            'properties': {
                              'securityRules': '[parameters(\'nsg\').securityRules]'
                            }
                          }                          
                        ]
                        'outputs': {
                          'nsgPolicyParam': {
                            'type': 'object'
                            'value': {
                              '[reference(resourceId(\'Microsoft.Network/networkSecurityGroups\', parameters(\'nsg\').name), \'2021-02-01\', \'full\').location]': {
                                'id': '[resourceId(\'Microsoft.Network/networkSecurityGroups\', parameters(\'nsg\').name)]'
                              }
                              'disabled': {
                                'id': ''
                              }
                            }
                          }
                          'routePolicyParam': {
                            'type': 'object'
                            'value': {
                              '[reference(resourceId(\'Microsoft.Network/routeTables\', parameters(\'routeTable\').name), \'2021-02-01\', \'full\').location]': {
                                'id': '[resourceId(\'Microsoft.Network/routeTables\', parameters(\'routeTable\').name)]'
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
                    'apiVersion': '2021-06-01'
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
                          'value': '[parameters(\'dnsServers\')]'
                        }
                        'routeTable': {
                          'value': '[reference(concat(subscription().id, \'/resourceGroups/\', \'${resourceGroupName}\', \'/providers/Microsoft.Resources/deployments/\', \'${deploymentName}\'), \'2019-10-01\').outputs.routePolicyParam.value]'
                        }
                        'nsg': {
                          'value': '[reference(concat(subscription().id, \'/resourceGroups/\', \'${resourceGroupName}\', \'/providers/Microsoft.Resources/deployments/\', \'${deploymentName}\'), \'2019-10-01\').outputs.nsgPolicyParam.value]'
                        }
                      }
                      'notScopes': ''
                      'nonComplianceMessages': [
                        {
                          'message': 'Corporate network configuration'
                        }
                      ]
                    }
                  }                  
                ]
              }
              'parameters': {
                'routeTable': {
                  'value': '[parameters(\'routeTable\')]'
                }
                'nsg': {
                  'value': '[parameters(\'nsg\')]'
                }
                'dnsServers': {
                  'value': '[parameters(\'dnsServers\')]'
                }
                'location': {
                  'value': '[parameters(\'location\')]'
                }
              }
            }
          }
        }
      }
    }
    parameters: {
      routeTable:{
        type: 'Object'
      }
      nsg:{
        type: 'Object'
      }
      dnsServers:{
        type: 'Array'
      }
      location:{
        type: 'String'
        metadata: {
          strongType: 'location'
        }
      }
    }
  }
}

output policyId string = policy.id
