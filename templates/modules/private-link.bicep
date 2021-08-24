param name string
param location string = resourceGroup().location
param serviceId string
param groupId string
param subnetId string = '/subscriptions/1bf7826c-f416-49a3-9183-2b6bf2fc5317/resourceGroups/eus-prd-corenetwork-rg/providers/Microsoft.Network/virtualNetworks/vnet-prd-eus-privatelink-10.10.255.0_24/subnets/sub-prd-eus-privatelink-endpoints-10.10.255.0_24'

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
