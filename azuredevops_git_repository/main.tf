resource "azuredevops_git_repository" "azuredevops_git_repository" {
  project_id           = data.azuredevops_project.azuredevops_project.id
  name                 = "Sample Import an Existing Repository"
  initialization {
    init_type = "Import"
    source_type = "Git"
    source_url = "https://github.com/euliancom/Azure-demo"
  }
}
