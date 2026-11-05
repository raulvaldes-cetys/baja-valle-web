# GitHub Actions authenticates with OIDC: no Azure secret is stored in the repository
resource "azurerm_user_assigned_identity" "github" {
  name                = "id-${local.name}-web-github"
  location            = data.azurerm_resource_group.main.location
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.tags
}

resource "azurerm_federated_identity_credential" "github_main" {
  name                = "github-main"
  resource_group_name = data.azurerm_resource_group.main.name
  parent_id           = azurerm_user_assigned_identity.github.id
  issuer              = "https://token.actions.githubusercontent.com"
  subject             = "repo:${var.github_repository}:ref:refs/heads/main"
  audience            = ["api://AzureADTokenExchange"]
}

resource "azurerm_role_assignment" "github_acr_push" {
  scope                = data.azurerm_container_registry.main.id
  role_definition_name = "AcrPush"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}

resource "azurerm_role_assignment" "github_deploy" {
  scope                = azurerm_container_app.web.id
  role_definition_name = "Contributor"
  principal_id         = azurerm_user_assigned_identity.github.principal_id
}
