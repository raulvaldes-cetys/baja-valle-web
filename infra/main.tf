locals {
  name = "bajavalle"
  tags = {
    project = "baja-valle"
    env     = "prod"
    owner   = var.owner
    course  = "cloud-computing"
  }
}

data "azurerm_client_config" "current" {}

# Shared resources owned by baja-valle-service/infra
data "azurerm_resource_group" "main" {
  name = "rg-${local.name}-prod"
}

data "azurerm_container_app_environment" "main" {
  name                = "cae-${local.name}-prod"
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_container_registry" "main" {
  name                = var.container_registry_name
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_container_app" "api" {
  name                = "ca-${local.name}-api"
  resource_group_name = data.azurerm_resource_group.main.name
}
