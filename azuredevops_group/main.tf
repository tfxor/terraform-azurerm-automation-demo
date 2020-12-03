
resource "azuredevops_group" "azuredevops_group" {
  scope        = data.azuredevops_project.azuredevops_project.id
  display_name = "Test group"
  description  = "Test description"

  members = [
    data.azuredevops_group.tf-project-readers.descriptor,
    data.azuredevops_group.tf-project-contributors.descriptor
  ]
}
