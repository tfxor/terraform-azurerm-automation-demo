resource "azuredevops_variable_group" "azuredevops_variable_group" {
  project_id   = data.azuredevops_project.azuredevops_project.id
  name         = "Infrastructure Pipeline Variables"
  description  = "Managed by Terraform"
  allow_access = true

  variable {
    name  = "FOO"
    value = "BAR"
  }
}

resource "azuredevops_build_definition" "azuredevops_build_definition" {
  project_id = data.azuredevops_project.azuredevops_project.id
  name       = "Sample Build Definition"
  path       = "\\ExampleFolder"

  ci_trigger {
    use_yaml = true
  }

  repository {
    repo_type   = "TfsGit"
    repo_id     = data.azuredevops_git_repository.terraform_azurerm_automation_demo.id
    branch_name = data.azuredevops_git_repository.terraform_azurerm_automation_demo.default_branch
    yml_path    = "azure-pipelines.yml"
  }

  variable_groups = [
    azuredevops_variable_group.azuredevops_variable_group.id
  ]

  variable {
    name  = "PipelineVariable"
    value = "Go Microsoft!"
  }

  variable {
    name      = "PipelineSecret"
    secret_value     = "ZGV2cw"
    is_secret = true
  }
}
