targetScope = 'managementGroup'

param resourceGroupName string = 'rg-prod-eus-corpnetwork'

var routes    = json(loadTextContent('parameters/firewall-routes.json'))
var nsgs      = json(loadTextContent('parameters/nsgs.json'))
var tags      = json(loadTextContent('parameters/networkwatcher-tags.json'))
var location  = deployment().location
var description   = '${toUpper(location)} - Deploy corporate network policies'

module nsgAndRoute 'modules/policy-network-config.bicep' = {
  name: 'createPolicy'
  params: {
    description: description
    nsgList: nsgs
    policyName: description
    resourceGroupName: resourceGroupName
    routeTables: routes
    tags: tags
    location: location
  }
}
