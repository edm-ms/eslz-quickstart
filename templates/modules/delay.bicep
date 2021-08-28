targetScope = 'managementGroup'

param time string = utcNow()
var uniqueName = guid(time)

@batchSize(1)
resource delayLoop 'Microsoft.Resources/deployments@2021-04-01' = [for i in range(0, 10): {
  name: '${uniqueName}-${i}'
  location: deployment().location
  properties: {
    mode: 'Incremental'
    template: {
      '\$schema': 'https://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentTemplate.json#'
      contentVersion: '1.0.0.0'
      parameters: {}
      resources: []
      outputs: {}
    }
  }
}]
