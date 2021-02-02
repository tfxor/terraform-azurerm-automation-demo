resource "azurerm_storage_container" "terraform_azurerm_automation_demo_storage_container" {
  name                  = "terraform_azurerm_automation_demo_storage_container"
  storage_account_name  = data.azurerm_storage_account.terraform_azurerm_automation_demo_storage_account.name
  container_access_type = "private"
}
