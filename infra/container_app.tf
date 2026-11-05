locals {
  port = 4321

  settings = {
    NODE_ENV      = "production"
    HOST          = "0.0.0.0"
    PORT          = tostring(local.port)
    API_URL       = "https://${data.azurerm_container_app.api.ingress[0].fqdn}"
    COOKIE_SECURE = "true"
  }
}

# Own identity: the dashboard only pulls its image, it never reads the API secrets
resource "azurerm_user_assigned_identity" "web" {
  name                = "id-${local.name}-web"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_role_assignment" "web_acr_pull" {
  scope                = data.azurerm_container_registry.main.id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_user_assigned_identity.web.principal_id
}

resource "azurerm_container_app" "web" {
  name                         = "ca-${local.name}-web"
  container_app_environment_id = data.azurerm_container_app_environment.main.id
  resource_group_name          = data.azurerm_resource_group.main.name
  revision_mode                = "Single"
  tags                         = local.tags

  identity {
    type         = "UserAssigned"
    identity_ids = [azurerm_user_assigned_identity.web.id]
  }

  registry {
    server   = data.azurerm_container_registry.main.login_server
    identity = azurerm_user_assigned_identity.web.id
  }

  ingress {
    external_enabled           = true
    target_port                = local.port
    allow_insecure_connections = false

    traffic_weight {
      latest_revision = true
      percentage      = 100
    }
  }

  template {
    min_replicas = 0
    max_replicas = 1

    container {
      name   = "web"
      image  = "${data.azurerm_container_registry.main.login_server}/baja-valle-web:${var.image_tag}"
      cpu    = 0.25
      memory = "0.5Gi"

      dynamic "env" {
        for_each = local.settings
        content {
          name  = env.key
          value = env.value
        }
      }

      liveness_probe {
        transport = "HTTP"
        path      = "/"
        port      = local.port
      }

      readiness_probe {
        transport = "HTTP"
        path      = "/"
        port      = local.port
      }
    }
  }

  lifecycle {
    ignore_changes = [template[0].container[0].image]
  }

  depends_on = [azurerm_role_assignment.web_acr_pull]
}
