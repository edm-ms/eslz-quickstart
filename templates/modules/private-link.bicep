param name string
param location string = resourceGroup().location
param serviceId string
param groupId string
param subnetId string

resource plink 'Microsoft.Network/privateEndpoints@2021-02-01' = {
 name: name
 location: location
 properties: {
   privateLinkServiceConnections: [
     {
       name: name
       properties: {
         privateLinkServiceId: serviceId
         groupIds: [
          groupId
         ]
       }
     }
   ]
 subnet: {
   id: subnetId
 }
 }
}
