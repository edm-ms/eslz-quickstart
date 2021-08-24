param purpose string = 'newnetwork'
param routeTable string = '/subscriptions/1bf7826c-f416-49a3-9183-2b6bf2fc5317/resourceGroups/eus-prd-corenetwork-rg/providers/Microsoft.Network/virtualHubs/eus-prd-hub/hubRouteTables/defaultRouteTable'
param vnetId string = ''
param hubName string = 'eus-prd-hub'

resource connection 'Microsoft.Network/virtualHubs/hubVirtualNetworkConnections@2020-08-01' = {
 name: '${hubName}/${purpose}'
 properties:{
   allowHubToRemoteVnetTransit:true
   allowRemoteVnetToUseHubVnetGateways:true
   enableInternetSecurity:true
   routingConfiguration:{
     associatedRouteTable:{
       id: routeTable
     }
     propagatedRouteTables:{
       labels:[
         'default'
       ]
       ids:[
         {
           id: routeTable
         }
       ]
     }
   }
   remoteVirtualNetwork:{
     id: vnetId
   }
 }
}
