#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "refactor_spaces_app_example_proxy_vpc" {
  source  = "aws-ia/vpc/aws"
  version = "3.1.0"
  # insert the 3 required variables here

  name       = "vpc-application-example-proxy"
  cidr_block = "192.168.10.0/24"
  az_count   = 2

  subnets = {
    private = {
      name_prefix = "private-application-example-proxy"
      netmask     = 27
    }
  }
}

module "refactor_spaces" {
  source  = "aws-ia/refactor-spaces/aws"
  version = "0.1.0"

  environment_name        = "unicorn-dev"
  environment_description = "AWS Migration Hub Refactor Spaces environment for Unicorn Enterprises."
  applications = [
    {
      application_name         = "Unistore"
      proxy_type               = "REGIONAL"
      application_proxy_vpc_id = module.refactor_spaces_app_example_proxy_vpc.vpc_attributes.id
      apigateway_stage_name    = "api"
    }
  ]
  services = [
    {
      application_name = "Unistore"
      name             = "legacy"
      description      = "The legacy monolithic application entry point"
      endpoint_type    = "URL"
      url_endpoint     = "http://legacy-unicorns.example.com/"
      vpc_id           = "vpc-XXYYZZ"
      routes = [
        {
          source_path  = "/"
          route_active = true
        }
      ]
    },
    {
      application_name = "Unistore"
      name             = "Unistore-AddToCartService"
      description      = "The new AddToCart Microservice"
      endpoint_type    = "LAMBDA"
      lambda_arn       = "arn:aws:lambda:us-east-1:999999999999:function:AddToCart"
      routes = [
        {
          source_path         = "/unicorns/basket"
          include_child_paths = false
          http_verbs          = ["POST", "GET"]
          route_active        = true
        }
      ]
    }
  ]
}