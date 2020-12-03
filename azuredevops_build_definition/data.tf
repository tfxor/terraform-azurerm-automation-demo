data "azuredevops_project" "azuredevops_project" {
  name = "terraform-azurerm-automation-demo"
}

data "azuredevops_git_repository" "terraform_azurerm_automation_demo" {
  project_id = data.azuredevops_project.azuredevops_project.id
  name       = "Sample Import an Existing Repository"
}
