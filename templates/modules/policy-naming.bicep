targetScope = 'managementGroup'

param resourceType string
param nameMatch string
param mode string = 'Indexed'
param description string
param policyName string

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
            'equals': resourceType
          }
          {
            'not': {
              'anyOf': [
                {
                  'field': 'name'
                  'like': nameMatch
                }
              ]
            }
          }
        ]
      }
      'then': {
        'effect': 'deny'
      }
    }
  }
}

output policyId string = policy.id
