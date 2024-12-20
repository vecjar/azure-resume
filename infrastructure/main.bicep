@description('Provide the name for the application. This name is also used in other resource names')
param appName string

@description('custom domain that should be cors enabled')
param cors string

@description('Get the resource group location and tenant id')
param location string = resourceGroup().location

// a 4 character suffix to add to the various names of Azure resources to help them be unique
var appSuffix = substring(uniqueString(resourceGroup().id),0,4)


// creates the cosmos db account and database
module cosmos './modules/cosmosdb.bicep' = {
  name: 'cosmos-deployment'
  params:{
    cosmosAccountName: 'cosmos-${appName}-${appSuffix}'
    location: location
  }
}

// creates a Log Analytics + Application Insights instance
module logAnalytics './modules/loganalytics.bicep' = {
  name: 'log-analytics-deployment'
  params: {
    appName: appName
    location: location
  }
}

// creates an azure function app and other resources azure functions needs
module azureFunctions_api './modules/functionapp.bicep' = {
  name: 'functions-app-deployment-api'
  params: {
    appName: appName
    location: location
    appNameSuffix: appSuffix
    cors: cors
    appInsightsInstrumentationKey: logAnalytics.outputs.instrumentationKey
  }
  dependsOn: [
    logAnalytics
  ]
}

// creates cdn profile
module cdn './modules/cdn.bicep' = {
  name: 'cdn-deployment'
  params: {
    location: location
    profileName: toLower('${appName}${appSuffix}')
  }
}
