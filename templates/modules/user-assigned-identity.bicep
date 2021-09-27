param uaiName string
param location string = resourceGroup().location

resource uai 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: uaiName
  location: location
}

output uaiId string = uai.id
