resource "azurerm_storage_blob" "terraform_azurerm_automation_demo_storage_blob" {
  name                   = "my-awesome-content.zip"
  storage_account_name   = data.azurerm_storage_account.terraform_azurerm_automation_demo_storage_account.outputs.name
  storage_container_name = data.azurerm_storage_container.terraform_azurerm_automation_demo_storage_container.outputs.name
  type                   = "Block"
  source                 = "some-local-file.zip"
}
