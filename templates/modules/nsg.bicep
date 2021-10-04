param nsgList array

resource nsgs 'Microsoft.Network/networkSecurityGroups@2021-02-01' = [for nsg in nsgList: {
  name: nsg.name
  location: nsg.location
}]
