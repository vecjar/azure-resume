param location string
param functionRuntime string = 'dotnet'
param appName string
param cors string

@description('Id of a existing keyvault that will be used to store and retrieve keys in this deployment')
param keyVaultName string

@description('User-assigned managed identity that will be attached to this function and will have power to connect to different resources.')
param managedSystemIdentityRbacId string

@description('The name of the role or service of this function. Example: Api CommandHandler, EventHandler')
param appInternalServiceName string = 'api'

@description('Application insights instrumentation key.')
param appInsightsInstrumentationKey string

param deploymentDate string = utcNow()

param appNameSuffix string

// Generate function app name
var functionAppName = 'func-${appName}-${appInternalServiceName}-${appNameSuffix}'
var appServiceName = 'ASP-${appName}-${appInternalServiceName}-${appNameSuffix}'

// Remove dashes for storage account name
var storageAccountName =  toLower(format('stg{0}', replace('${appInternalServiceName}-${appNameSuffix}', '-', '')))

// Create Storage Account
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: storageAccountName
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    minimumTlsVersion:'TLS1_2'
    encryption: {
      services: {
        file: {
          keyType: 'Account'
          enabled: true
        }
        blob: {
          keyType: 'Account'
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
  }
}

// Create Blob Services for Storage Account
resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

// Create App Service (Consumption Plan)
resource appService 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: appServiceName
  location: location
  kind: 'functionapp'
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
    size: 'Y1'
    family: 'Y'
    capacity: 0
  }
  properties: {
    maximumElasticWorkerCount: 1
    targetWorkerCount: 0
    targetWorkerSizeId: 0
  }
}

// Create Function App
resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: functionAppName
  location: location
  identity: {
    type: 'SystemAssigned, UserAssigned'
    userAssignedIdentities: {
      '${managedSystemIdentityRbacId}': {}
    }
  }
  kind: 'functionapp'
  properties: {
    keyVaultReferenceIdentity: managedSystemIdentityRbacId
    enabled: true
    hostNameSslStates: [
      {
        name: '${functionAppName}.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
      {
        name: '${functionAppName}.scm.azurewebsites.net'
        sslState: 'Disabled'
        hostType: 'Standard'
      }
    ]
    serverFarmId: appService.id
    siteConfig: {
      appSettings: [
        // Directly pass the Storage Account connection string (bypassing Key Vault)
        {
          name: 'AzureWebJobsStorage'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTAZUREFILECONNECTIONSTRING'
          value: 'DefaultEndpointsProtocol=https;AccountName=${storageAccount.name};AccountKey=${storageAccount.listKeys().keys[0].value};EndpointSuffix=${environment().suffixes.storage}'
        }
        {
          name: 'WEBSITE_CONTENTSHARE'
          value: toLower(functionAppName)
        }
        {
          name: 'APPINSIGHTS_INSTRUMENTATIONKEY'
          value: appInsightsInstrumentationKey
        }
        {
          name: 'APPLICATIONINSIGHTS_CONNECTION_STRING'
          value: 'InstrumentationKey=${appInsightsInstrumentationKey}'
        }
        {
          name: 'FUNCTIONS_WORKER_RUNTIME'
          value: functionRuntime
        }
        {
          name: 'FUNCTIONS_EXTENSION_VERSION'
          value: '~4'
        }
        {
          name: 'AzureResumeConnectionString'
          value: 'your_connection_string_here'  // If you have another connection string, set it here
        }
      ]
      cors: {
        allowedOrigins: [cors]
      }
      use32BitWorkerProcess: true
    }
    scmSiteAlsoStopped: false
    clientAffinityEnabled: false
    clientCertEnabled: false
    hostNamesDisabled: false
    dailyMemoryTimeQuota: 0
    httpsOnly: false
    redundancyMode: 'None'
  }
}
