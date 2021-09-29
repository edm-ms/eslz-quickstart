targetScope = 'managementGroup'

param resourceType string
param resourceName string
param mode string = 'Indexed'
param policyName string
param roleIds array

resource policy 'Microsoft.Authorization/policyDefinitions@2020-09-01' = {
  name: policyName
  properties: {
    description: 'This policy deploys resource locks for ${resourceName}s'
    displayName: 'Deploy resource lock for ${resourceName}s'
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
          }
          'roleDefinitionIds': roleIds
          'deployment': {
            'properties': {
              'mode': 'incremental'
              'parameters': {
                'resourceName': {
                  'value': '[field(\'name\')]'
                }
              }
              'template': {
                '$schema': 'https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json'
                'contentVersion': '1.0.0.0'
                'parameters': {
                  'resourceName': {
                    'type': 'string'
                  }
                }
                'resources': [
                    {
                      'type': '${resourceType}/providers/locks'
                      'name': '[concat(parameters(\'resourceName\'), \'/Microsoft.Authorization/vaultLock\')]'
                      'apiVersion': '2016-09-01'
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

output policyId string = policy.id
