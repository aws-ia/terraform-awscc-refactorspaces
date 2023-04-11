<!-- BEGIN_TF_DOCS -->
# Example : Deploying and configuring AWS Refactor Spaces in a single account

The following example deploys AWS Refactor Spaces components within a single AWS Account including the environment, application and all service routes. This is recommended only for proof-of-concept or testing purposes; in Production it is recommended that micro-services are deployed in separate AWS accounts in order to simplify implementation of least-privilege access models for a single application scope, simplify internal resource tracking and charge-back and service limits and quotas.

This example would deploy the following:
* An Amazon VPC "vpc-application-example-proxy" with IPv4 CIDR 192.168.10.0/24 and two 27-bit private subnets
* A AWS Migration Hub Refactor Spaces environment named "unicorn-dev"
* A AWS Migration Hub Refactor Spaces application named "Unistore"
* A AWS Migration Hub Refactor Spaces service "Unistore-legacy" pointing to a monolithic application deployed on Amazon EC2/ECS/EKS or similar services running in a VPC with a DNS name `http://legacy-unicorns.example.com/` acting as the default route
* A AWS Migration Hub Refactor Spaces service "Unistore-AddToCartService" pointing at a microservice deployed as AWS Lambda Function with the ARN `arn:aws:lambda:us-east-1:999999999999:function:AddToCart`.
* A route that sends `POST` and `GET` requests to `/unicorns/basket` to the AWS Lambda function

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.49.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_refactor_spaces"></a> [refactor\_spaces](#module\_refactor\_spaces) | ../../ | n/a |
| <a name="module_refactor_spaces_app_example_proxy_vpc"></a> [refactor\_spaces\_app\_example\_proxy\_vpc](#module\_refactor\_spaces\_app\_example\_proxy\_vpc) | aws-ia/vpc/aws | 3.1.0 |

## Resources

No resources.

## Inputs

No inputs.

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applications"></a> [applications](#output\_applications) | Collection of AWS Migration Hub Refactor Spaces Application managed by or used.  <br><br>Example:<pre>applications = [<br>  {<br>    api_gateway_id = "a0abcdefg1o1"<br>    nlb_arn = "arn:aws:elasticloadbalancing:us-east-1:99999999999:loadbalancer/net/refactor-spaces-nlb-XXXX/YYYY",<br>    vpc_link_id = "00abcde"<br>    application = {<br>      "application_identifier" = "app-BSXbxAPn1r",<br>      "arn" = "arn:aws:refactor-spaces:us-east-1:627561228761:environment/env-ZoiD5hlRyz/application/app-BSXbxAPn1r",<br>      "environment_identifier" = "env-ZoiD5hlRyz",<br>      ...<br>            <all attributes of AWS Migration Hub Refactor Spaces Application: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_application><br>    }<br>    application_proxy_vpc_attributes = {<br>      <all attributes of the awscc_ec2_vpc data source: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/ec2_vpc><br>    }<br>  }<br>]</pre> |
| <a name="output_environment_id"></a> [environment\_id](#output\_environment\_id) | The unique identifier for the AWS Migration Hub Refactor Spaces environment. |
| <a name="output_services"></a> [services](#output\_services) | Collection of AWS Migration Hub Refactor Spaces Services and associated routes.  <br><br>Example:<pre>services = [<br>  {<br>    "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/service/svc-XYZ"<br>    "name" = "legacy",<br>    description = "The legacy monolithic application entry point"<br>    routes = [<br>      {<br>        "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/route/rte-ABCD"<br>        "route_identifier" = "rte-ABCD"<br>        "route_type": "DEFAULT"<br>        ...<br>        <all attributes of AWS Migration Hub Refactor Spaces Route: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_route><br>      }<br>    ]<br>    ...<br>    <all attributes of AWS Migration Hub Refactor Spaces Service: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_service><br>  }<br>]</pre> |
| <a name="output_transit_gateway_id"></a> [transit\_gateway\_id](#output\_transit\_gateway\_id) | Unique identifier of AWS Transit Gateway for the AWS Migration Hub Refactor Spaces environment. |
<!-- END_TF_DOCS -->