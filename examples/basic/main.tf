#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "refactor_spaces_app_example_proxy_vpc" {
  source  = "aws-ia/vpc/aws"
  version = "3.1.0"

  name       = var.proxy_vpc_name
  cidr_block = var.proxy_vpc_cidr_block
  az_count   = 2

  subnets = {
    private = {
      name_prefix = "private-${var.proxy_vpc_name}"
      netmask     = 27
    }
  }
}

module "refactor_spaces" {
  source  = "aws-ia/refactorspaces/awscc"
  version = "0.0.2"

  environment_name        = var.environment_name
  environment_description = var.environment_description
  applications = [
    {
      application_name         = var.application_name
      proxy_type               = var.application_proxy_type
      application_proxy_vpc_id = module.refactor_spaces_app_example_proxy_vpc.vpc_attributes.id
      apigateway_stage_name    = var.application_stage_name
    }
  ]
  services = [
    {
      application_name = var.application_name
      name             = var.display_name_monolith_server
      description      = var.description_monolith_server
      endpoint_type    = "URL"
      url_endpoint     = var.url_endpoint_monolith
      vpc_id           = var.vpc_id_monolith
      routes = [
        {
          source_path  = "/"
          route_active = true
        }
      ]
    },
    {
      application_name = var.application_name
      name             = var.display_name_lambda_microservice
      description      = var.description_lambda_microservice
      endpoint_type    = "LAMBDA"
      lambda_arn       = var.lambda_arn_microservice
      routes = [
        {
          source_path         = var.source_path_lambda_microservice
          include_child_paths = false
          http_verbs          = var.http_verbs_lambda_microservice
          route_active        = true
        }
      ]
    }
  ]
}
