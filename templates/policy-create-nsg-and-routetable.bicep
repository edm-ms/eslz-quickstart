targetScope = 'managementGroup'

var routes = json(loadTextContent('parameters/firewall-routes.json'))
var nsgs   = json(loadTextContent('parameters/nsgs.json'))
var tags   = json(loadTextContent('parameters/networkwatcher-tags.json'))

module nsgAndRoute 'modules/policy-sub-basenetworking.bicep' = {
  name: 'createPolicy'
  params: {
    description: 'Create transit route tables and default NSG' 
    nsgList: nsgs
    policyName: 'Create transit route tables and default NSG' 
    resourceGroupName: 'rg-prod-global-transit'
    routeTables: routes
    tags: tags
  }
}
