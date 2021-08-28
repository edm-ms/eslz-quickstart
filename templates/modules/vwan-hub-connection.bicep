param purpose string
param routeTable string 
param vnetId string
param hubName string

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
