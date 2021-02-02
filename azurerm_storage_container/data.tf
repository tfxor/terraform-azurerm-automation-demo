data "azurerm_storage_account" "terraform_azurerm_automation_demo_storage_account" {
  name                = "armautomationdemoaccount"
  resource_group_name = "azurermautomationdemogroup"
}
