param name string
param location string = resourceGroup().location
param ghRepo string
param ghAccountName string

var rootFolder = '/'
var branchName = 'main'

resource adf 'Microsoft.DataFactory/factories@2018-06-01' = {
  name: name
  location: location
  properties: {
    repoConfiguration: {
      type: 'FactoryGitHubConfiguration'
      repositoryName: ghRepo
      accountName: ghAccountName
      collaborationBranch: branchName
      rootFolder: rootFolder
    }
  }
}
