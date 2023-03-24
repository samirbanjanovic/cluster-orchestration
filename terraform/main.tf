// setup terraform
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

// register azurerm terraform provider
provider "azurerm" {
  features {}
}

// create resource group
resource "azurerm_resource_group" "fleet" {
  name     = var.resource_group_name
  location = var.location
}

// create kubernetes fleet manager
resource "azurerm_kubernetes_fleet_manager" "fleet" {
  hub_profile {
    dns_prefix = var.fleet_name
  }
  location            = azurerm_resource_group.fleet.location
  name                = var.fleet_name
  resource_group_name = azurerm_resource_group.fleet.name
}

resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.vnet_name}"
  address_space       = ["10.0.0.0/8"]
  location            = azurerm_resource_group.fleet.location
  resource_group_name = azurerm_resource_group.fleet.name

  // using the input subnet list create the subnets
  subnet {
    name           = "${var.fleet_name}-manager-subnet"
    address_prefix = "10.1.0.0/24"
  }
}

resource "azurerm_log_analytics_workspace" "capz" {
  name                = "logs-${var.cluster_name}"
  location            = var.location
  resource_group_name = azurerm_resource_group.fleet.name
  retention_in_days   = 30
}


# create a new cluster and place it in the manager subnet
resource "azurerm_kubernetes_cluster" "capz" {
  name                = var.cluster_name
  location            = azurerm_resource_group.fleet.location
  resource_group_name = azurerm_resource_group.fleet.name
  dns_prefix          = var.cluster_name

  default_node_pool {
    name           = "default"
    node_count     = 1
    vm_size        = "Standard_d2as_v5"
    vnet_subnet_id = azurerm_virtual_network.default.subnet.*.id[0]
    upgrade_settings {
        max_surge       = 1
    }
  }

  identity {
    type = "SystemAssigned"
  }

  # turn on container insights
  oms_agent {
    log_analytics_workspace_id = azurerm_log_analytics_workspace.capz.id
  }

  tags = {
    Type = "Cluster Manager"
    Workload = "CAPZ"
  }
}

# see https://learn.microsoft.com/en-us/azure/azure-monitor/containers/container-insights-custom-metrics?tabs=cli#enable-custom-metrics
# The preview feature for role assignment this will be added automatically.
# For now we need to add it manually.
# The id is hard to find, it is part of the "oms_agent" output attribute and was moved from addon_profiles in the later version of the providers.
# Use object_id and specify check AAD otherwise it will go into an infinite loop.
# https://github.com/hashicorp/terraform-provider-azurerm/pull/7056
resource "azurerm_role_assignment" "omsagent-aks" {
  scope                            = azurerm_kubernetes_cluster.capz.id
  role_definition_name             = "Monitoring Metrics Publisher"
  principal_id                     = azurerm_kubernetes_cluster.capz.oms_agent[0].oms_agent_identity[0].object_id
  skip_service_principal_aad_check = false
}