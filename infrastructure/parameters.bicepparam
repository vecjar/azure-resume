// parameters file to input of a couple of parameters

using 'main.bicep'

@description('Provide the name for the application. This name is also used in other resource names')
param appName = 'AzureCloudResume'

@description('provide your custom domain url that should be enabled by cors')
param cors = 'https://www.tienvieri.fi'
