param provisioningServiceName string
param iotHubConnectionString string
param skuName string
param skuUnits int

resource deviceService 'Microsoft.Devices/provisioningServices@2020-01-01' = {
  location: resourceGroup().location
  name: provisioningServiceName
  sku: {
    name: skuName
    capacity: skuUnits
  }
  properties: {
    iotHubs: [
      {
        connectionString: iotHubConnectionString
        location: resourceGroup().location
      }
    ]
  }
}
