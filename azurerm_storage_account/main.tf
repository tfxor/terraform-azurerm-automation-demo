resource "azurerm_storage_account" "terraform_azurerm_automation_demo_storage_account" {
  name                     = "terraform_azurerm_automation_demo_storage_account"
  resource_group_name      = data.azurerm_resource_group.terraform_azurerm_automation_demo_group.name
  location                 = data.azurerm_resource_group.terraform_azurerm_automation_demo_group.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}
