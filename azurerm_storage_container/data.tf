data "azurerm_storage_account" "terraform_azurerm_automation_demo_storage_account" {
  name                = "terraform_azurerm_automation_demo_storage_account"
  resource_group_name = "terraform-azurerm-automation-demo-group"
}
