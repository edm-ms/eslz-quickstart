param purpose string
param routeTableId string 
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
       id: routeTableId
     }
     propagatedRouteTables:{
       labels:[
         'default'
       ]
       ids:[
         {
           id: routeTableId
         }
       ]
     }
   }
   remoteVirtualNetwork:{
     id: vnetId
   }
 }
}
