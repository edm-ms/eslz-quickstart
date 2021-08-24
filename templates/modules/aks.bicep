param clusterName string
param nodeCount int = 1
param vmSize string = 'Standard_Ds2_v2'
param aksSubnet string
param aksVersion string
param poolName string
param location string = resourceGroup().location
param uami string
param aadAdminObjectId string
param tags object

var uamiObj = {
  '${uami}': {}
}

resource aks 'Microsoft.ContainerService/managedClusters@2021-05-01' = {
  name: clusterName
  location: location
  tags: tags
  properties: {
    enableRBAC: true
    kubernetesVersion: aksVersion
    dnsPrefix: 'local'
    aadProfile: {
      enableAzureRBAC: true
      managed: true
      adminGroupObjectIDs: [
        aadAdminObjectId
      ]
    }
    agentPoolProfiles: [
      {
        name: poolName
        enableAutoScaling: true
        count: nodeCount
        minCount: 1
        maxCount: 3
        vmSize: vmSize
        vnetSubnetID: aksSubnet
        mode: 'System'
        nodeLabels: tags
        osDiskSizeGB: 64
      }
    ]
    networkProfile: {
      networkPlugin: 'azure'
      serviceCidr: '10.88.254.0/23'
      dnsServiceIP: '10.88.254.10'
      dockerBridgeCidr: '172.17.0.1/16'
    }
  }
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: uamiObj
    }
}
