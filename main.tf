/*
  AWS Migration Hub Refactor Spaces: Environment
  Create AWS Migration Hub Refactor Spaces environment if no environment_id provided.
*/
module "refactor_spaces_environment" {
  count = local.create_environment ? 1 : 0

  source                   = "./modules/tf-refactor-spaces-environment"
  environment_name         = var.environment_name
  environment_description  = var.environment_description
  provision_network_bridge = var.provision_network_bridge
  shared_to_principals     = var.shared_to_principals
  resource_tags            = local.tags
}

# Search for existing AWS Migration Hub Refactor Spaces environment with var.environment_id if not creating
data "awscc_refactorspaces_environment" "environment" {
  count = local.create_environment ? 0 : 1
  id    = var.environment_id
}

/*
  AWS Migration Hub Refactor Spaces: Applications
  Create AWS Migration Hub Refactor Spaces applications (Strangler-Fig-Proxy).
*/
module "refactor_spaces_application" {
  for_each = { for application in var.applications : application.application_name => application }

  source                   = "./modules/tf-refactor-spaces-application"
  environment_id           = local.environment.environment_identifier
  application_name         = each.value.application_name
  proxy_type               = each.value.proxy_type
  apigateway_stage_name    = each.value.apigateway_stage_name
  application_proxy_vpc_id = each.value.application_proxy_vpc_id
  #resource_tags            = local.tags  # Tagging is not currently supported, to be enabled in future
}

/*
  AWS Migration Hub Refactor Spaces: Applications
  Return data objects for one or more AWS Migration Hub Refactor Spaces applications for use in service configuration.
*/
data "awscc_refactorspaces_application" "application" {
  count = length(local.application_id_collection) # Using length as for_each keys would derived from resource attributes determined after apply if creating applications
  id    = local.application_id_collection[count.index]
}

/*
  AWS Migration Hub Refactor Spaces: Service
  Create refactor spaces services and routing constructs.

  Enforce explicit ordering of service hosting the default route (create first/destroy last)
*/
module "refactor_spaces_service_defaults" {
  for_each = { for service in var.services : "${service.application_name}_${service.name}" => service if contains(service.routes[*].source_path, "/") }

  source         = "./modules/tf-refactor-spaces-service"
  environment_id = local.environment.environment_identifier
  application_id = local.application_objects[each.value.application_name].application_identifier
  name           = each.value.name
  description    = each.value.description
  endpoint_type  = each.value.endpoint_type
  lambda_arn     = each.value.lambda_arn
  url_endpoint   = each.value.url_endpoint
  health_url     = each.value.health_url
  vpc_id         = each.value.vpc_id
  routes         = each.value.routes
}

module "refactor_spaces_service_non_defaults" {
  for_each = { for service in var.services : "${service.application_name}_${service.name}" => service if !contains(service.routes[*].source_path, "/") }

  source         = "./modules/tf-refactor-spaces-service"
  environment_id = local.environment.environment_identifier
  application_id = local.application_objects[each.value.application_name].application_identifier
  name           = each.value.name
  description    = each.value.description
  endpoint_type  = each.value.endpoint_type
  lambda_arn     = each.value.lambda_arn
  url_endpoint   = each.value.url_endpoint
  health_url     = each.value.health_url
  vpc_id         = each.value.vpc_id
  routes         = each.value.routes

  # To enforce explicit resource create/delete ordering of services with default routes
  depends_on = [
    module.refactor_spaces_service_defaults
  ]
}
