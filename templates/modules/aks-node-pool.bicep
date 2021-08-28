param clusterName string
param nodePoolName string
param nodeCount int
param maxNodeCount int
param vmSize string = 'Standard_d8s_v3'
param tags object

resource aksNodes 'Microsoft.ContainerService/managedClusters/agentPools@2021-05-01' = {
  name: '${clusterName}/${nodePoolName}'
  properties: {
    count: nodeCount
    enableAutoScaling: true
    type: 'VirtualMachineScaleSets'
    maxCount: maxNodeCount
    minCount: nodeCount
    nodeLabels: tags
    osDiskSizeGB: 64
    vmSize: vmSize
    tags: tags
    mode: 'User'
    osDiskType: 'Ephemeral'
    spotMaxPrice: -1
    scaleSetEvictionPolicy: 'Delete'
    scaleSetPriority: 'Spot'
  }
}
