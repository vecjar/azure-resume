// // This creates storage account static websites enabled.
// // Since static websites option cannot be done via Bicep, a deployment script is used.

// param appName string
// param location string

// @description('The name of the storage account to use for site hosting.')
// param storageAccountName string = substring(toLower('stgweb${appName}${uniqueString(resourceGroup().id)}'), 0, 24)


// resource storageAccount 'Microsoft.Storage/storageAccounts@2021-06-01' = {
//   name: storageAccountName
//   location: location
//   kind: 'StorageV2'
//   sku: {
//     name: 'Standard_LRS'
//   }
// }

// resource contributorRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
//   scope: subscription()
//   // This is the Storage Account Contributor role, which is the minimum role permission we can give
//   name: '17d1049b-9a84-46fb-8f53-869881c3d3ab'
// }

// resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
//   name: 'DeploymentScriptIdentity'
//   location: location
// }

// resource roleAssignment 'Microsoft.Authorization/roleAssignments@2020-04-01-preview' = {
//   scope: storageAccount
//   name: guid(resourceGroup().id, managedIdentity.id, contributorRoleDefinition.id)
//   properties: {
//     roleDefinitionId: contributorRoleDefinition.id
//     principalId: managedIdentity.properties.principalId
//     principalType: 'ServicePrincipal'
//   }
// }


// output staticWebsiteUrl string = storageAccount.properties.primaryEndpoints.web
