@minLength(2)
@maxLength(2)
param nsgList array

resource nsgs 'Microsoft.Network/networkSecurityGroups@2021-02-01' = [for nsg in nsgList: {
  name: nsg.name
  location: nsg.location
}]

output policyParameter object = {
  '${nsgs[0].location}': { 
    id: nsgs[0].id
  }
  '${nsgs[1].location}': { 
    id: nsgs[1].id
  }
  'disabled': { 
    id: ''
  }
}
