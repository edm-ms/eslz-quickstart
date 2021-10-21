param localVNetName string
param remoteVNetName string
param remoteVnetId string
@allowed([
  true
  false
])
param allowGwTransit bool
@allowed([
  true
  false
])
param useRemoteGw bool

resource peering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2020-11-01' = {
 name: '${localVNetName}/peer-to-${remoteVNetName}'
 properties:{
   allowForwardedTraffic: true
   allowVirtualNetworkAccess: true
   allowGatewayTransit: allowGwTransit
   useRemoteGateways:useRemoteGw
   remoteVirtualNetwork:{
     id: remoteVnetId
   }
   }
 }
