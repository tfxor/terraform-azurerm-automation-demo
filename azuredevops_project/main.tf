resource "azuredevops_project" "azuredevops_project" {
  name               = "terraform-azurerm-automation-demo"
  description        = "Terraform Azure DevOps Automation Demo"
  visibility         = "private"
  version_control    = "Git"
  work_item_template = "Agile"
}
