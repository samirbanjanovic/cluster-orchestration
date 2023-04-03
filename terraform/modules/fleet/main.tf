// Since fleet is in preview we're going to use azapi provider
// once fleet is GA we can use azurerm provider.  Migration is 
// made simple by using the AzAPI2AzureRM tool: https://github.com/Azure/azapi2azurerm/releases
terraform {
  required_providers {
    azapi = {
      source  = "azure/azapi"
      version = ">=1.1.0"
    }
  }
}

// create fleet manager resource
resource "azapi_resource" "fleet" {
  type      = "Microsoft.ContainerService/fleets@2022-09-02-preview"
  name      = var.fleet_name
  location  = var.location
  parent_id = var.resource_group_id
  body = jsonencode({
    properties = {
      hubProfile = {
        dnsPrefix = var.fleet_name
      }
    }
  })
}

resource "azapi_resource" "fleet_member" {
  type      = "Microsoft.ContainerService/fleets/members@2022-09-02-preview"
  for_each  = var.fleet_members
  name      = each.value.clusterName
  parent_id = azapi_resource.fleet.id
  body = jsonencode({
    properties = {
      clusterResourceId = each.value.clusterResourceId
    }
  })
}
