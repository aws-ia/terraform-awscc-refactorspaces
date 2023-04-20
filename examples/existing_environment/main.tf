module "refactor_spaces_microservice_x" {
  source  = "aws-ia/refactorspaces/aws"
  version = "0.1.0"

  environment_id = var.environment_id
  application_id = var.application_id
  services = [
    {
      application_name = var.application_name
      name             = var.display_name_lambda_microservice
      description      = var.description_lambda_microservice
      endpoint_type    = "LAMBDA"
      lambda_arn       = var.lambda_arn_microservice
      routes = [
        {
          source_path         = var.source_path_lambda_microservice
          include_child_paths = true
          http_verbs          = var.http_verbs_lambda_microservice
          route_active        = true
        }
      ]
    }
  ]
}