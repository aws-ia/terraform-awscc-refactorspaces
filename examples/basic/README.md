<!-- BEGIN_TF_DOCS -->
# Example : Deploying and configuring AWS Refactor Spaces in a single account

The following example deploys AWS Refactor Spaces components within a single AWS Account including the environment, application and all service routes. This is recommended only for proof-of-concept or testing purposes; in Production it is recommended that micro-services are deployed in separate AWS accounts in order to simplify implementation of least-privilege access models for a single application scope, simplify internal resource tracking and charge-back and service limits and quotas.

<p align="center">
  <img src="https://raw.githubusercontent.com/aws-ia/terraform-aws-refactorspaces/main/images/aws_migration_hub_refactor_spaces_basic.png" alt="Simple" width="75%">
</p>

Figure 1. Example configuration of AWS Migration Hub Refactor Spaces with a monolithic application 'Unishop' with the AddToCart strangled as a Lambda microservice.

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
| <a name="module_refactor_spaces"></a> [refactor\_spaces](#module\_refactor\_spaces) | aws-ia/refactorspaces/awscc | 0.1.0 |
| <a name="module_refactor_spaces_app_example_proxy_vpc"></a> [refactor\_spaces\_app\_example\_proxy\_vpc](#module\_refactor\_spaces\_app\_example\_proxy\_vpc) | aws-ia/vpc/aws | 3.1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The display name in AWS Migration Hub Refactor Spaces for the application being strangled. | `string` | `"Unistore"` | no |
| <a name="input_application_proxy_type"></a> [application\_proxy\_type](#input\_application\_proxy\_type) | The accessibility of the Amazon API Gateway that is deployed by AWS Migration Hub Refactor Spaces for the application. `REGIONAL` APIs are publicly accessible in the current Region. `PRIVATE` APIs are accessible only from VPCs. Default: REGIONAL. | `string` | `"REGIONAL"` | no |
| <a name="input_application_stage_name"></a> [application\_stage\_name](#input\_application\_stage\_name) | The stage name which will be configured on Amazon API Gateway by AWS Migration Hub Refactor Spaces for the application. | `string` | `"api"` | no |
| <a name="input_description_lambda_microservice"></a> [description\_lambda\_microservice](#input\_description\_lambda\_microservice) | A description for the the Lambda based microservice configured as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith. | `string` | `"The new AddToCart Microservice"` | no |
| <a name="input_description_monolith_server"></a> [description\_monolith\_server](#input\_description\_monolith\_server) | A description for the the AWS Migration Hub Refactor Spaces service for the monolithic application. | `string` | `"The legacy monolithic application entry point"` | no |
| <a name="input_display_name_lambda_microservice"></a> [display\_name\_lambda\_microservice](#input\_display\_name\_lambda\_microservice) | A display name for a Lambda based microservice configured as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith. | `string` | `"Unistore-AddToCartService"` | no |
| <a name="input_display_name_monolith_server"></a> [display\_name\_monolith\_server](#input\_display\_name\_monolith\_server) | A display name for the AWS Migration Hub Refactor Spaces service for the monolithic application. | `string` | `"legacy"` | no |
| <a name="input_environment_description"></a> [environment\_description](#input\_environment\_description) | A description for the AWS Migration Hub Refactor Spaces environment. | `string` | `"AWS Migration Hub Refactor Spaces environment for Unicorn Enterprises."` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | The name of the AWS Migration Hub Refactor Spaces environment that will be created. | `string` | `"Unistore-Dev"` | no |
| <a name="input_http_verbs_lambda_microservice"></a> [http\_verbs\_lambda\_microservice](#input\_http\_verbs\_lambda\_microservice) | A list of HTTP methods AWS Migration Hub Refactor Spaces will use to to match traffic destined for the new microservice. | `string` | <pre>[<br>  "POST",<br>  "GET"<br>]</pre> | no |
| <a name="input_lambda_arn_microservice"></a> [lambda\_arn\_microservice](#input\_lambda\_arn\_microservice) | The Amazon Resource Name (ARN) of the Lambda function to use as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith. | `string` | `"arn:aws:lambda:us-east-1:999999999999:function:AddToCart"` | no |
| <a name="input_proxy_vpc_cidr_block"></a> [proxy\_vpc\_cidr\_block](#input\_proxy\_vpc\_cidr\_block) | A 24-bit IPv4 CIDR to for the Amazon Virtual Private Cloud (VPC) created to host the VPC Link for Refactor Spaces to access the monolithic application. | `string` | `"192.168.10.0/24"` | no |
| <a name="input_proxy_vpc_name"></a> [proxy\_vpc\_name](#input\_proxy\_vpc\_name) | A name for a the Amazon Virtual Private Cloud (VPC) created to host the VPC Link for Refactor Spaces to access the monolithic application. | `string` | `"vpc-application-example-proxy"` | no |
| <a name="input_source_path_lambda_microservice"></a> [source\_path\_lambda\_microservice](#input\_source\_path\_lambda\_microservice) | The path AWS Migration Hub Refactor Spaces will use to match traffic destined for the new microservice. Paths must start with / and are relative to the base of the application. | `string` | `"/unicorns/basket"` | no |
| <a name="input_url_endpoint_monolith"></a> [url\_endpoint\_monolith](#input\_url\_endpoint\_monolith) | A fully-qualified HTTP/HTTPS URI for the entry point of the current monolithic application running. | `string` | `"http://legacy-unicorns.example.com/"` | no |
| <a name="input_vpc_id_monolith"></a> [vpc\_id\_monolith](#input\_vpc\_id\_monolith) | A Amazon Virtual Private Cloud (VPC) id of the VPC where the current monolithic application (defined in `var.url_endpoint_monolith` running. | `string` | `"http://legacy-unicorns.example.com/"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applications"></a> [applications](#output\_applications) | Collection of AWS Migration Hub Refactor Spaces Application managed by or used.  <br><br>Example:<pre>applications = [<br>  {<br>    api_gateway_id = "a0abcdefg1o1"<br>    nlb_arn = "arn:aws:elasticloadbalancing:us-east-1:99999999999:loadbalancer/net/refactor-spaces-nlb-XXXX/YYYY",<br>    vpc_link_id = "00abcde"<br>    application = {<br>      "application_identifier" = "app-BSXbxAPn1r",<br>      "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ZoiD5hlRyz/application/app-BSXbxAPn1r",<br>      "environment_identifier" = "env-ZoiD5hlRyz",<br>      ...<br>            <all attributes of AWS Migration Hub Refactor Spaces Application: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_application><br>    }<br>    application_proxy_vpc_attributes = {<br>      <all attributes of the awscc_ec2_vpc data source: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/ec2_vpc><br>    }<br>  }<br>]</pre> |
| <a name="output_environment"></a> [environment](#output\_environment) | AWS Migration Hub Refactor Spaces environment resource attributes. Full output of [`awscc_refactorspaces_environment`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_environment) |
| <a name="output_services"></a> [services](#output\_services) | Collection of AWS Migration Hub Refactor Spaces Services and associated routes.  <br><br>Example:<pre>services = [<br>  {<br>    "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/service/svc-XYZ"<br>    "name" = "legacy",<br>    description = "The legacy monolithic application entry point"<br>    routes = [<br>      {<br>        "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/route/rte-ABCD"<br>        "route_identifier" = "rte-ABCD"<br>        "route_type": "DEFAULT"<br>        ...<br>        <all attributes of AWS Migration Hub Refactor Spaces Route: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_route><br>      }<br>    ]<br>    ...<br>    <all attributes of AWS Migration Hub Refactor Spaces Service: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_service><br>  }<br>]</pre> |
<!-- END_TF_DOCS -->