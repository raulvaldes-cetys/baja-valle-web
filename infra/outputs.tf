output "dashboard_url" {
  value = "https://${azurerm_container_app.web.ingress[0].fqdn}"
}

output "github_deploy" {
  description = "Repository variables for the deploy workflow"
  value = {
    AZURE_CLIENT_ID       = azurerm_user_assigned_identity.github.client_id
    AZURE_TENANT_ID       = data.azurerm_client_config.current.tenant_id
    AZURE_SUBSCRIPTION_ID = var.subscription_id
    AZURE_RESOURCE_GROUP  = data.azurerm_resource_group.main.name
    ACR_NAME              = data.azurerm_container_registry.main.name
    WEB_APP_NAME          = azurerm_container_app.web.name
  }
}
