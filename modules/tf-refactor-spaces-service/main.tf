/*
  AWS Migration Hub Refactor Spaces: Service
  Create an AWS Migration Hub Refactor Spaces service
*/
resource "awscc_refactorspaces_service" "current" {
  application_identifier = var.application_id
  environment_identifier = var.environment_id
  name                   = var.name
  description            = var.description
  endpoint_type          = var.endpoint_type
  vpc_id                 = var.vpc_id

  lambda_endpoint = var.endpoint_type == "LAMBDA" ? {
    arn = var.lambda_arn
  } : null

  url_endpoint = var.endpoint_type == "URL" ? {
    url        = var.url_endpoint
    health_url = var.health_url != null ? var.health_url : null # Prevent update forcing replacement
  } : null

}

/*
  AWS Migration Hub Refactor Spaces: Routes (default)
  Creates default routes for the Refactor Spaces services. Create first to ensure correct ordering implementation.
*/
resource "awscc_refactorspaces_route" "default" {
  for_each = { for default_route in var.routes : default_route.source_path => default_route if default_route.source_path == "/" }

  application_identifier = var.application_id
  environment_identifier = var.environment_id
  service_identifier     = awscc_refactorspaces_service.current.service_identifier
  route_type             = "DEFAULT"

  default_route = {
    activation_state = each.value.route_active ? "ACTIVE" : "INACTIVE"
  }

  # Create an explict dependency to ensure correct ordering during create/delete/replace
  depends_on = [
    awscc_refactorspaces_service.current
  ]

  # Ignore changes to the Service Identifier after initial creation
  lifecycle {
    ignore_changes = [
      service_identifier
    ]

    # Replace if the upstream service needs to be replaced
    replace_triggered_by = [
      awscc_refactorspaces_service.current.service_identifier
    ]
  }
}

/*
  AWS Migration Hub Refactor Spaces: Routes (non-defaults)
  Create non-default routes for the Refactor Spaces services
*/
resource "awscc_refactorspaces_route" "non_default" {
  for_each = { for route in var.routes : "${route.source_path}_${join("_", route.http_verbs)}" => route if route.source_path != "/" }

  application_identifier = var.application_id
  environment_identifier = var.environment_id
  service_identifier     = awscc_refactorspaces_service.current.service_identifier
  route_type             = "URI_PATH"

  uri_path_route = {
    activation_state    = each.value.route_active ? "ACTIVE" : "INACTIVE"
    include_child_paths = each.value.include_child_paths != null ? each.value.include_child_paths : false
    methods             = each.value.http_verbs != null ? each.value.http_verbs : []
    source_path         = each.value.source_path
  }

  # The default route must be the first type created
  depends_on = [
    awscc_refactorspaces_service.current,
    awscc_refactorspaces_route.default
  ]

  # Ignore changes to the Service Identifier after initial creation
  lifecycle {
    ignore_changes = [
      service_identifier
    ]

    # Replace if the upstream service needs to be replaced
    replace_triggered_by = [
      awscc_refactorspaces_service.current.service_identifier
    ]
  }
}
