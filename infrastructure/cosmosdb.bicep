// The following will create a cosmos db account with serverless plan, as well as a database and a container that match with app backend code

@maxLength(30)
param cosmosAccountName string
param location string
param keyVaultName string


resource cosmosAccount 'Microsoft.DocumentDB/databaseAccounts@2023-09-15' = {
  name: toLower(cosmosAccountName)
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    publicNetworkAccess: 'Enabled'
    enableFreeTier: false
    databaseAccountOfferType: 'Standard'
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
      maxIntervalInSeconds: 5
      maxStalenessPrefix: 100
    }
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: false
      }
    ]
    capabilities: [
      {
        name: 'EnableServerless'
      }
    ]
  }
}


resource cosmosDb_database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2023-09-15' = {
  name: 'AzureResume'
  parent: cosmosAccount
  properties: {
    resource: {
      id: 'AzureResume'
    }
  }
}

resource cosmosDb_container 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers@2023-09-15' = {
  name: 'Counter'
  parent: cosmosDb_database
  properties: {
    resource: {
      id: 'Counter'
      partitionKey: {
        paths: [
          '/id'
        ]
      }
    }
  }
}


module setCosmosConnectionString 'setsecret.bicep' = {
  name: 'setCosmosConnectionString'
  params: {
    keyVaultName: keyVaultName
    secretName: 'AzureResumeConnectionString'
    secretValue: cosmosAccount.listConnectionStrings().connectionStrings[0].connectionString
  }
}

output cosmosAccountName string = cosmosAccountName
