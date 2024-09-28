@minLength(1)
@maxLength(23)
@description('Provide a name for the storage account.  Use only lower case letters and numbers. The name must be unique across Azure.')
param storageAccountName string = 'store${uniqueString(resourceGroup().id)}'

@minLength(1)
@maxLength(63)
@description('Provide a name for the storage table.  Use only lower case letters and numbers. The name must be unique across Azure.')
param tableName string = 'db${name}'

param location string = resourceGroup().location


resource storageAccount 'Microsoft.Storage/storageAccounts@2023-05-01' = {
  kind: 'StorageV2'
  location: location
  name: storageAccountName
  sku: {
    name: 'Standard_ZRS'
  }
  properties: {
    allowBlobPublicAccess: false
    allowSharedKeyAccess: false
    defaultToOAuthAuthentication: true
    minimumTlsVersion: 'TLS1_2'
    networkAcls: {
      bypass: 'AzureServices'
      defaultAction: 'Allow'
    }
    accessTier: 'Hot'
    encryption: {
      requireInfrastructureEncryption: true
      keySource: 'Microsoft.Storage'
      services: {
        table: {
          enabled: true
          keyType: 'Account'
        }
      }
    }
    allowCrossTenantReplication: false
    allowedCopyScope: 'AAD'
    dnsEndpointType: 'Standard'
    supportsHttpsTrafficOnly: true
  }
}

resource storageTableServices 'Microsoft.Storage/storageAccounts/tableServices@2023-05-01' = {
  parent: storageAccount
  name: 'default'
}

resource storageTable 'Microsoft.Storage/storageAccounts/tableServices/tables@2023-05-01' = {
  parent: storageTableServices
  name: tableName
}