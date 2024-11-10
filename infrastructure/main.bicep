// This bicep file and its modules create various Azure resources needed in the "Azure resume":
// Cosmos db account, database and container, function app (and storage account, log analytics workspace, appinsights related to it)
// blob storage for static websites, and CDN profile and endpoint.
// All you need to do is provide an appName and your custom domain below, other parameters are filled in


@description('Provide the name for the application. This name is also used in other resource names')
param appName string

@description('custom domain that should be cors enabled')
param cors string

@description('Get the resource group location and tenant id')
param location string = resourceGroup().location
param tenantId string = tenant().tenantId

// a 4 character suffix to add to the various names of Azure resources to help them be unique
var appSuffix = substring(uniqueString(resourceGroup().id),0,4)


// creates an user-assigned managed identity that will be used by different azure resources to access each other.
module managedSystemIdentity 'msi.bicep' = {
  name: 'managed-system-identity-deployment'
  params: {
    location: location
    managedIdentityName: '${appName}Identity'
  }
}


// creates a key vault in this resource group
module keyvault 'keyvault.bicep' = {
  name: 'keyvault-deployment'
  params: {
    location: location
    appName: appName
    tenantId: tenantId
  }
}


// creates the cosmos db account and database with a container configured
module cosmos 'cosmosdb.bicep' = {
  name: 'cosmos-deployment'
  params:{
    cosmosAccountName: 'cosmos-${appName}-${appSuffix}'
    location: location
    keyVaultName: keyvault.outputs.keyVaultName
  }
}

// creates a Log Analytics + Application Insights instance
module logAnalytics 'loganalytics.bicep' = {
  name: 'log-analytics-deployment'
  params: {
    appName: appName
    location: location
  }
}

// creates an azure function app and other resources azure functions needs
module azureFunctions_api 'functionapp.bicep' = {
  name: 'functions-app-deployment-api'
  params: {
    appName: appName
    location: location
    appNameSuffix: appSuffix
    cors: cors
    appInsightsInstrumentationKey: logAnalytics.outputs.instrumentationKey
    keyVaultName: keyvault.outputs.keyVaultName
    managedSystemIdentityRbacId: managedSystemIdentity.outputs.id
  }
  dependsOn: [
    keyvault
    logAnalytics
  ]
}

// creates blob storage for static website
module staticWebStorage 'storageweb.bicep' = {
  name: 'static-web-storage-deployment'
  params: {
    appName: appName
    location: location
  }
}


// creates cdn profile, endpoint and custom domain
module cdn 'cdn.bicep' = {
  name: 'cdn-deployment'
  params: {
    location: location
    profileName: toLower('${appName}${appSuffix}')
    endpointName: toLower('${appName}${appSuffix}')
    originUrl: replace(replace('${staticWebStorage.outputs.staticWebsiteUrl}', 'https://', ''), '/', '')
  }
}
