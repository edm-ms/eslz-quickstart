targetScope = 'managementGroup'

param resourceType string
param resourceName string
param mode string = 'Indexed'
param roleIds array
param managementGroup string

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: 'Deploy resource lock for ${resourceName}'
  properties: {
    description: 'This policy deploys resource locks for ${resourceName}'
    displayName: 'Deploy resource lock for ${resourceName}'
    mode: mode
    policyRule: {
      'if': {
        'allOf': [
          {
            'field': 'type'
            'equals': resourceType
          }
        ]
      }
      'then': {
        'effect': 'deployIfNotExists'
        'details': {
          'type': 'Microsoft.Authorization/locks'
          'roleDefinitionIds': roleIds
          'existenceCondition': {
              'field': 'Microsoft.Authorization/locks/level'
              'equals': 'CanNotDelete'
            }
            'deployment': {
              'properties': {
                'mode': 'incremental'
                'parameters': {
                  'resourceName': {
                    'value': '[field(\'name\')]'
                  }
                  'resourceType': {
                    'value': resourceType
                  }
                }
                'template': {
                  '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json'
                  'contentVersion': '1.0.0.0'
                  'parameters': {
                    'resourceName': {
                      'type': 'string'
                    }
                    'resourceType': {
                      'type': 'string'
                    }
                  }
                  'resources': [
                      {
                        'type': 'Microsoft.Authorization/locks'
                        'scope': '[concat(parameters(\'resourceType\'), parameters(\'resourceName\'))]'
                        'name': 'setByPolicy'
                        'apiVersion': '2017-04-01'
                        'properties': {
                          'level': 'CanNotDelete'
                          'notes': 'Lock applied by Azure Policy'
                        }
                    }
                  ]
                }
              }
            } 
          }
      }
    }
  }
}

output policyId string = policy.id
output policyIdFull string = '/providers/Microsoft.Management/managementGroups/${managementGroup}/providers/${policy.id}'
