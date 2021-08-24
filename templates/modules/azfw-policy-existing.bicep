var firewallPolicy                  = 'fwpol-prd-global-corporate'
var firewallRg                      = 'rg-prd-eus-firewall'
var firewallSub                     = '1bf7826c-f416-49a3-9183-2b6bf2fc5317'

resource azureFirewall 'Microsoft.Network/firewallPolicies@2021-02-01' existing = {
  name: firewallPolicy
  scope: resourceGroup(firewallSub, firewallRg)
}

output firewall object = {
  currentFirewall: azureFirewall
}
