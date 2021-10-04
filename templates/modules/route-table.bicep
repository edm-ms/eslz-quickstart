
param routeTableName string
param location string = resourceGroup().location
param routes array

resource routeTable 'Microsoft.Network/routeTables@2021-02-01' = {
  name: routeTableName
  location: location
  properties: {
    disableBgpRoutePropagation: true
    routes: routes
  }
}

output routeTableId string = routeTable.id
