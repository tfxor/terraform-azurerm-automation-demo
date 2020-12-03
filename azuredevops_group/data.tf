data "azuredevops_project" "azuredevops_project" {
  name = "terraform-azurerm-automation-demo"
}

data "azuredevops_group" "tf-project-readers" {
  project_id = data.azuredevops_project.azuredevops_project.id
  name       = "Readers"
}

data "azuredevops_group" "tf-project-contributors" {
  project_id = data.azuredevops_project.azuredevops_project.id
  name       = "Contributors"
}
