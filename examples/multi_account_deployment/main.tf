#####################################################################################
# Terraform module examples are meant to show an _example_ on how to use a module
# per use-case. The code below should not be copied directly but referenced in order
# to build your own root module that invokes this module
#####################################################################################

module "refactor_spaces_environment" {
  # source  = "aws-ia/refactor-spaces/aws"
  # version = ">= 1.0.0"
  source = "../../"

  providers = {
    aws   = aws.central-mgmt
    awscc = awscc.central-mgmt
  }

  environment_name         = "Unicorns"
  environment_description  = "AWS Migration Hub Refactor Spaces environment for Unicorn Enterprises."
  provision_network_bridge = true
  shared_to_principals     = var.unistore_modernized_principals
}

/*
  Read the environment after the apply with the Application Account provider
*/
data "awscc_refactorspaces_environment" "unicorns" {
  provider = awscc.central-mgmt
  id       = module.refactor_spaces_environment.environment.environment_identifier
}

/*
  Configure Refactor Spaces Application for modernization
  Create a VPC to act a Refactor Spaces Proxy VPC for example Application
*/
module "refactor_spaces_app_proxy_vpc" {
  source  = "aws-ia/vpc/aws"
  version = "3.1.0"

  providers = {
    aws   = aws.unistore-frontend
    awscc = awscc.unistore-frontend
  }

  name       = "vpc-unistore-application-proxy"
  cidr_block = var.unistore_modernized_proxy_vpc_cidr
  az_count   = 2

  subnets = {
    private = {
      name_prefix = "private-unistore-application-proxy"
      cidrs       = [cidrsubnet(var.unistore_modernized_proxy_vpc_cidr, 2, 0), cidrsubnet(var.unistore_modernized_proxy_vpc_cidr, 2, 1)]
    }
  }
  tags = local.vpc_tags
}

module "refactor_spaces_application_unishop" {
  # source  = "aws-ia/refactor-spaces/aws"
  # version = ">= 1.0.0"
  source = "../../"

  providers = {
    aws   = aws.unistore-frontend
    awscc = awscc.unistore-frontend
  }

  environment_id = local.refactor_spaces_environment_id
  applications = [
    {
      application_name         = "Unistore"
      proxy_type               = "REGIONAL"
      application_proxy_vpc_id = module.refactor_spaces_app_proxy_vpc.vpc_attributes.id
      apigateway_stage_name    = "api"
    }
  ]
}

data "awscc_refactorspaces_application" "unistore" {
  provider = awscc.unistore-frontend
  id       = module.refactor_spaces_application_unishop.applications["Unistore"].id
}

/*
  Deploy the default path to the monolith for the newly created Refactor Spaces application
  in the monolith account
*/
module "refactor_spaces_unishop_monolith" {
  # source  = "aws-ia/refactor-spaces/aws"
  # version = ">= 1.0.0"
  source = "../../"

  providers = {
    aws   = aws.unistore-frontend
    awscc = awscc.unistore-frontend
  }

  environment_id = local.refactor_spaces_environment_id
  application_id = local.refactor_spaces_application_id
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
    }
  ]

  depends_on = [
    module.refactor_spaces_application_unishop
  ]
}

/*
  Deploy the microservice services
*/
module "refactor_spaces_unishop_add_cart" {
  # source  = "aws-ia/refactor-spaces/aws"
  # version = ">= 1.0.0"
  source = "../../"

  providers = {
    aws   = aws.unistore-userservice
    awscc = awscc.unistore-userservice
  }

  environment_id = local.refactor_spaces_environment_id
  application_id = local.refactor_spaces_application_id
  services = [
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

  depends_on = [
    module.refactor_spaces_application_unishop
  ]
}

