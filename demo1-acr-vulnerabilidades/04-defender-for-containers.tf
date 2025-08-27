resource "azurerm_security_center_subscription_pricing" "defender_containers" {
  resource_type = "ContainerRegistry"
  tier          = "Standard"
}
