locals {
  tags = merge(
    var.resource_tags,
    {
      Terraform = "Managed by Terraform"
    }
  )

  refactor_spaces_environment_id = data.awscc_refactorspaces_environment.unicorns.id
  refactor_spaces_application_id = data.awscc_refactorspaces_application.unistore.application_identifier

  # Dynamically add refactor-spaces:environment-id tag if Refactor Spaces is in use to vpc resources to ensure RAM functions correctly
  vpc_tags = module.refactor_spaces_environment.environment_id != null ? merge(
    local.tags,
    {
      "refactor-spaces:environment-id" = module.refactor_spaces_environment.environment_id
    }
  ) : local.tags
}