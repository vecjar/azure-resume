// This is used to store secrets to key vault

param keyVaultName string
param secretName string
@secure()
param secretValue string

resource secret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = {
  name: '${keyVaultName}/${secretName}'
  properties: {
    value: secretValue
  }
}
