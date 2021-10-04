param routeTables array

resource rt 'Microsoft.Network/routeTables@2021-02-01' = [for routeTable in routeTables: {
  name: routeTable.name
  location: routeTable.location
  properties: {
    disableBgpRoutePropagation: true
    routes: [
      {
        name: routeTable.routename
        properties: {
          addressPrefix: routeTable.properties.addressPrefix
          nextHopIpAddress: routeTable.properties.nextHopIpAddress
          nextHopType: routeTable.properties.nextHopType
        }
      }
    ]
  }
}]
