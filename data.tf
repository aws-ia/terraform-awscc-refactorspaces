locals {
  tags = merge(
    var.resource_tags,
    {
      Terraform = "Managed by Terraform"
    }
  )

  ##################################################################
  # Feature toggles for whether:
  # - Create or reference a AWS Migration Hub Refactor Spaces environment
  # - Create or reference AWS Migration Hub Refactor Spaces application(s)

  # if var.environment_id is passed, assume create = `false` and environment id comes from data.awscc_refactorspaces_environment
  create_environment = var.environment_id == null ? true : false
  environment        = local.create_environment ? module.refactor_spaces_environment[0].environment : data.awscc_refactorspaces_environment.environment[0]

  # if var.application_id is passed, assume create = `false` and application id's come from the created awscc_refactorspaces_application resources in the module
  create_application        = var.application_id == null ? true : false
  application_id_collection = local.create_application ? [for k, v in module.refactor_spaces_application : v.application.id] : ["${local.environment.environment_identifier}|${var.application_id}"]
  application_objects       = { for application_object in data.awscc_refactorspaces_application.application : application_object.name => application_object } # Transform collection to map to enable addressing resource by application name

  service_objects = merge(module.refactor_spaces_service_defaults, module.refactor_spaces_service_non_defaults)
}