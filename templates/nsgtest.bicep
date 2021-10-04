
var nsgs   = json(loadTextContent('parameters/nsgs.json'))

module nsgss 'modules/nsg.bicep' = {
  name: 'test'
  params: {
    nsgList: nsgs
  }
}

output nsgObject object = nsgss.outputs.policyParameter
