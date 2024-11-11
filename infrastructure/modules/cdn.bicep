@description('Name of the CDN Profile')
param profileName string

@description('CDN SKU names')
param CDNSku string = 'Standard_Microsoft'

param location string

resource profile 'Microsoft.Cdn/profiles@2021-06-01' = {
  name: profileName
  location: location
  sku: {
    name: CDNSku
  }
}
