resource "azurerm_container_registry" "demo_acr" {
  name                = "demodevsecopsacr"
  resource_group_name = azurerm_resource_group.acr_rg.name
  location            = azurerm_resource_group.acr_rg.location
  sku                 = "Standard"
  admin_enabled       = false
}
