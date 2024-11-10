// This creates a managed identity, a role for it and role assignment. Managed identity is used to access key vault secrets

param managedIdentityName string
param location string

resource managedSystemIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: managedIdentityName
  location: location
}

resource keyVaultSecretsReaderRoleDefinition 'Microsoft.Authorization/roleDefinitions@2022-04-01' existing = {
  name: '4633458b-17de-408a-b874-0445c86b69e6'
}

resource MSIroleAssignment 'Microsoft.Authorization/roleAssignments@2022-04-01' = {
  name: guid(keyVaultSecretsReaderRoleDefinition.id, managedSystemIdentity.id, resourceGroup().id)
  scope: resourceGroup()
  properties: {
    roleDefinitionId: keyVaultSecretsReaderRoleDefinition.id 
    principalId: managedSystemIdentity.properties.principalId
    principalType: 'ServicePrincipal'
  }
}

output principalId string = managedSystemIdentity.properties.principalId
output clientId string = managedSystemIdentity.properties.clientId
output id string = managedSystemIdentity.id
