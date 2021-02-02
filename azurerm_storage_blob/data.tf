data "azurerm_storage_account" "terraform_azurerm_automation_demo_storage_account" {
  name                = "terraform_azurerm_automation_demo_storage_account"
  resource_group_name = "terraform-azurerm-automation-demo-group"
}

data "azurerm_storage_container" "terraform_azurerm_automation_demo_storage_container" {
  name                 = "terraform_azurerm_automation_demo_storage_container"
  storage_account_name = "terraform_azurerm_automation_demo_storage_account"
}
