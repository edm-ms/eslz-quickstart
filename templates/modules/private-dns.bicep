param dnsZone string

resource privateDns 'Microsoft.Network/privateDnsZones@2018-09-01' = {
  name: dnsZone
  location: 'global'
  properties: {}
}

output zoneId string = privateDns.id
