/*
  VPC: Application Proxy VPC
  Read the Application Proxy VPC object
*/
data "awscc_ec2_vpc" "application_proxy_vpc" {
  id = var.application_proxy_vpc_id
}

/*
  AWS Migration Hub Refactor Spaces: Application
  Create an AWS Migration Hub Refactor Spaces application (Strangler-Fig-Proxy)
*/
resource "awscc_refactorspaces_application" "current" {
  name                   = var.application_name
  vpc_id                 = data.awscc_ec2_vpc.application_proxy_vpc.id
  proxy_type             = "API_GATEWAY"
  environment_identifier = var.environment_id

  api_gateway_proxy = {
    endpoint_type = var.proxy_type
    stage_name    = var.apigateway_stage_name
  }

  /*
  # Tagging of AWS::RefactorSpaces::Application in non-environment owner account (multi-account deployment) not currently supported
  # due to dependent service (Amazon API Gateway) not supporting operation currently.
    tags = [
      for tag_key, tag_value in local.tags : {
        key   = tag_key
        value = tag_value
      }
    ]
  */

  # Tags can not be updated (throws update error for the resource)
  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}
