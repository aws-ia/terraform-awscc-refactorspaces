<!-- BEGIN_TF_DOCS -->
# Example: Deploying and configuring AWS Refactor Spaces in a single account

The following example deploys AWS Refactor Spaces components within a single AWS account including the environment, application, and all service routes. We recommend only using this for proof-of-concept or testing purposes. In production, deploy microservices in separate AWS accounts to simplify implementation of least-privilege access models for a single application scope, simplify internal resource tracking and chargeback, and service limits and quotas.

![Architecture for Migration Hub Refactor Spaces on AWS](https://raw.githubusercontent.com/aws-ia/terraform-awscc-refactorspaces/main/images/aws_migration_hub_refactor_spaces_basic.png)

Figure 1. Example configuration of AWS Migration Hub Refactor Spaces deployed with a monolithic application Unishop with a new AddToCart microservice, running as an AWS Lambda microservice.

As shown in the diagram, the solution in this example sets up the following:

* A highly available architecture that spans two Availability Zones.*
* One Virtual Private Cloud (VPC) to:
  ** Host a Network Load Balancer, deployed by AWS Migration Hub Refactor Spaces. Amazon API Gateway uses the Network Load Balancer and an AWS Transit Gateway attachment in the private subnet to communicate with workloads deployed in other VPCs. Amazon API Gateway is managed by AWS Migration Hub Refactor Spaces.*
* A second VPC to:
  ** Host the monolithic application Unistore legacy. Amazon API Gateway uses the Application Load Balancer and an AWS Transit Gateway attachment in the private subnet, and the Amazon API Gateway is managed by AWS Migration Hub Refactor Spaces.*
* In the private subnets of the second VPC:
  ** An Amazon Elastic Compute Cloud (Amazon EC2) instance to host the monolithic application Unistore legacy.*
* An Application Load Balancer to forward traffic to a Target group that contains the Amazon EC2 instances.*
* An AWS Migration Hub:
  ** Refactor Spaces environment configured to create a new AWS Transit Gateway. This environment is managed by AWS Migration Hub Refactor Spaces. An option is available to provision a network bridge for cross-account connectivity.
  ** An AWS Migration Hub Refactor Spaces application that creates an Amazon API Gateway.
* The following AWS Migration Hub Refactor Spaces services:
  ** Default service points to a monolithic application deployed on Amazon EC2. This service acts as the default route for traffic.
  ** AddToCart service points to a microservice deployed as an AWS Lambda function.
* A route that sends requests for the AddToCart domain to the Lambda function.
* A Network Load Balancer deployed in a provided VPC and connected to the Amazon API Gateway by AWS Migration Hub Refactor Spaces. This uses the VPC link feature.
* A Lambda function AddToCart that holds the modernized AddToCart business logic strangled from the Unistore legacy monolithic application.

*The Terraform module that deploys this solution does not include the components marked by asterisks but are provided as inputs and depicted to illustrate a real-world deployment scenario.

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
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | Display name in AWS Migration Hub Refactor Spaces for the strangled application. | `string` | `"Unistore"` | no |
| <a name="input_application_proxy_type"></a> [application\_proxy\_type](#input\_application\_proxy\_type) | Accessibility of Amazon API Gateway deployed by AWS Migration Hub Refactor Spaces. `REGIONAL` APIs are publicly accessible in the current AWS Region. `PRIVATE` APIs are accessible only from VPCs. Default: REGIONAL. | `string` | `"REGIONAL"` | no |
| <a name="input_application_stage_name"></a> [application\_stage\_name](#input\_application\_stage\_name) | Stage name configured on Amazon API Gateway by AWS Migration Hub Refactor Spaces. | `string` | `"api"` | no |
| <a name="input_description_lambda_microservice"></a> [description\_lambda\_microservice](#input\_description\_lambda\_microservice) | Description for Lambda-based microservice configured as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith. | `string` | `"The new AddToCart Microservice"` | no |
| <a name="input_description_monolith_server"></a> [description\_monolith\_server](#input\_description\_monolith\_server) | Description for AWS Migration Hub Refactor Spaces service for the monolithic application. | `string` | `"The legacy monolithic application entry point"` | no |
| <a name="input_display_name_lambda_microservice"></a> [display\_name\_lambda\_microservice](#input\_display\_name\_lambda\_microservice) | Display name for Lambda-based microservice configured as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith. | `string` | `"Unistore-AddToCartService"` | no |
| <a name="input_display_name_monolith_server"></a> [display\_name\_monolith\_server](#input\_display\_name\_monolith\_server) | Display name for AWS Migration Hub Refactor Spaces service for the monolithic application. | `string` | `"legacy"` | no |
| <a name="input_environment_description"></a> [environment\_description](#input\_environment\_description) | Description for AWS Migration Hub Refactor Spaces environment. | `string` | `"AWS Migration Hub Refactor Spaces environment for Unicorn Enterprises."` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of AWS Migration Hub Refactor Spaces environment. | `string` | `"Unistore-Dev"` | no |
| <a name="input_http_verbs_lambda_microservice"></a> [http\_verbs\_lambda\_microservice](#input\_http\_verbs\_lambda\_microservice) | List of HTTP methods AWS Migration Hub Refactor Spaces uses to match traffic destined for the new microservice. | `string` | <pre>[<br>  "POST",<br>  "GET"<br>]</pre> | no |
| <a name="input_lambda_arn_microservice"></a> [lambda\_arn\_microservice](#input\_lambda\_arn\_microservice) | ARN of Lambda function to use as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith. | `string` | `"arn:aws:lambda:us-east-1:999999999999:function:AddToCart"` | no |
| <a name="input_proxy_vpc_cidr_block"></a> [proxy\_vpc\_cidr\_block](#input\_proxy\_vpc\_cidr\_block) | A 24-bit IPv4 CIDR for Amazon VPC to host the link for AWS Refactor Spaces to access the monolithic application. | `string` | `"192.168.10.0/24"` | no |
| <a name="input_proxy_vpc_name"></a> [proxy\_vpc\_name](#input\_proxy\_vpc\_name) | Name for Amazon VPC to host the link for AWS Refactor Spaces to access the monolithic application. | `string` | `"vpc-application-example-proxy"` | no |
| <a name="input_source_path_lambda_microservice"></a> [source\_path\_lambda\_microservice](#input\_source\_path\_lambda\_microservice) | Path AWS Migration Hub Refactor Spaces uses to match traffic destined for the new microservice. Paths must start with / and are relative to the base of the application. | `string` | `"/unicorns/basket"` | no |
| <a name="input_url_endpoint_monolith"></a> [url\_endpoint\_monolith](#input\_url\_endpoint\_monolith) | Fully-qualified HTTP/HTTPS URI for the entry point of the current monolithic application running. | `string` | `"http://legacy-unicorns.example.com/"` | no |
| <a name="input_vpc_id_monolith"></a> [vpc\_id\_monolith](#input\_vpc\_id\_monolith) | Amazon VPC ID of current monolithic application running (defined in `var.url_endpoint_monolith`). | `string` | `"http://legacy-unicorns.example.com/"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applications"></a> [applications](#output\_applications) | Collection of AWS Migration Hub Refactor Spaces application managed by or used.<br><br>Example:<pre>applications = [<br>  {<br>    api_gateway_id = "a0abcdefg1o1"<br>    nlb_arn = "arn:aws:elasticloadbalancing:us-east-1:99999999999:loadbalancer/net/refactor-spaces-nlb-XXXX/YYYY",<br>    vpc_link_id = "00abcde"<br>    application = {<br>      "application_identifier" = "app-BSXbxAPn1r",<br>      "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ZoiD5hlRyz/application/app-BSXbxAPn1r",<br>      "environment_identifier" = "env-ZoiD5hlRyz",<br>      ...<br>            <all attributes of AWS Migration Hub Refactor Spaces Application: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_application><br>    }<br>    application_proxy_vpc_attributes = {<br>      <all attributes of the awscc_ec2_vpc data source: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/ec2_vpc><br>    }<br>  }<br>]</pre> |
| <a name="output_environment"></a> [environment](#output\_environment) | AWS Migration Hub Refactor Spaces environment resource attributes. Full output of [`awscc_refactorspaces_environment`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_environment). |
| <a name="output_services"></a> [services](#output\_services) | Collection of AWS Migration Hub Refactor Spaces services and associated routes.<br><br>Example:<pre>services = [<br>  {<br>    "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/service/svc-XYZ"<br>    "name" = "legacy",<br>    description = "The legacy monolithic application entry point."<br>    routes = [<br>      {<br>        "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/route/rte-ABCD"<br>        "route_identifier" = "rte-ABCD"<br>        "route_type": "DEFAULT"<br>        ...<br>        <all attributes of AWS Migration Hub Refactor Spaces Route: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_route><br>      }<br>    ]<br>    ...<br>    <all attributes of AWS Migration Hub Refactor Spaces Service: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_service><br>  }<br>]</pre> |
<!-- END_TF_DOCS -->