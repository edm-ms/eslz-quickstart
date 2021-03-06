param dnsZoneName string
param connectionName string
param vnetID string
@allowed([
  true
  false
])
param autoReg bool = false

resource privateDNS 'Microsoft.Network/privateDnsZones/virtualNetworkLinks@2020-06-01' = {
 name: '${dnsZoneName}/${connectionName}'
 location: 'global'
 properties:{
   virtualNetwork:{
     id: vnetID
   }
   registrationEnabled: autoReg
 }
}
