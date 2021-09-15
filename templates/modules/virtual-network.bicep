param vnetName string
param vnetAddressSpace array
param vnetDns array
param subnetList array

resource virtualNetwork 'Microsoft.Network/virtualNetworks@2021-02-01' = {
  name: vnetName
  properties: {
    addressSpace: {
      addressPrefixes: vnetAddressSpace
    }
    dhcpOptions: {
      dnsServers: vnetDns
    }
    subnets: [for subnet in subnetList: {
      name: subnet.name
      properties: {
        addressPrefix: subnet.address
      }
    }]
  }
}

output vnetId string = virtualNetwork.id
output subnetIds array = [for i in range(0, length(subnetList)): virtualNetwork.properties.subnets[i].id ]
