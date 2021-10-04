targetScope = 'managementGroup'

param rgName string = 'rg-prod-eus-corenetwork'
param routeTableName string = 'rt-prod-eus-firewall'
param location string = 'eastus'
param policyName string = 'Create core network resource group and route table'
param description string = 'Automatically deploy network resource group with route table'

var routes = json(loadTextContent('parameters/firewall-route-eastus.json'))
var tags = json(loadTextContent('parameters/networkwatcher-tags.json'))

module routeTablePolicy 'modules/policy-routetable.bicep' = {
  name: 'policyrt'
  params: {
    description: description
    policyName: policyName
    resourceGroupName: rgName
    location: location
    routes: routes
    routeTableName: routeTableName
    tags: tags
  }
}
