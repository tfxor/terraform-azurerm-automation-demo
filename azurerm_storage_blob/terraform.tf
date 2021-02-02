terraform {
  backend "azurerm" {
    resource_group_name  = "terraform-azurerm-automation-demo-resource-group"
    storage_account_name = "mitocgroup"
    container_name       = "automationdemo"
    key                  = "azurerm_storage_blob/terraform.tfstate"
  }
}
