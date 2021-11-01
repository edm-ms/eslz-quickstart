targetScope = 'managementGroup'

param resourceType string
param nameMatch array
param mode string = 'Indexed'
param description string
param policyName string

resource namePolicy 'Microsoft.Authorization/policyDefinitions@2021-06-01' = {
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
              'anyOf': nameMatch
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


output policyId string = namePolicy.id
