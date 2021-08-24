param collectionName string
param groupName string
param ruleName string
param sourceAddresses array
param targetFqdn string


resource ruleCollectionGroup 'Microsoft.Network/firewallPolicies/ruleCollectionGroups@2021-02-01' = {
  name: collectionName
  properties: {
    ruleCollections: [
      {
        ruleCollectionType: 'FirewallPolicyFilterRuleCollection'
        name: groupName
        action: {
          type: 'Allow'
        }
        rules: [
          {
            ruleType: 'ApplicationRule'
            name: ruleName
            sourceAddresses: sourceAddresses
            targetFqdns: [
              targetFqdn
            ]
            protocols: [
              {
                port: 1433
                protocolType: 'Https'
              }
            ]
          }
        ]
      }
    ]
  }
}
