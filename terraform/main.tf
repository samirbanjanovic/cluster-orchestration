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
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

// create kubernetes fleet manager
resource "azurerm_kubernetes_fleet_manager" "fleet" {
  location            = azurerm_resource_group.rg.location
  name                = var.fleet_name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_virtual_network" "default" {
  name                = "vnet-${var.main_net_name}"
  address_space       = ["10.0.0.0/8"]
  location            = var.location
  resource_group_name = azurerm_resource_group.default.name

  // using the input subnet list create the subnets
  subnet {
    name           = "${var.fleet_name}-manager-subnet"
    address_prefix = "10.0.0.0/24"
  }
}

# create a new cluster and place it in the manager subnet
resource "azurerm_kubernetes_cluster" "cluster" {
  name                = var.cluster_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
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

  role_based_access_control {
    enabled = true
  }

  tags = {
    Type = "Cluster Manager"
    Workload = "CAPZ"
  }
}

