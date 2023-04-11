<!-- BEGIN_TF_DOCS -->
# Terraform Module for AWS Migration Hub Refactor Spaces on AWS

## Overview
This module can be used to deploy AWS Migration Hub Refactor Spaces components. Common deployment examples can be found in [examples/](./examples). The module can be used to deploy Environments, Applications, Services & Routes or a subset of these resources to enable different use cases.

## Table of contents
- [Usage](#usage)
- [Contributing](#contributing)
- [Support and Feedback](#support-and-feedback)
- [Known Issues](#known-issues)
- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Usage
The simple example below builds a AWS Migration Hub Refactor Spaces environment with a single application and two services in a single AWS Account. Multi-account deployment examples can be found in [examples/](./examples).

```
module "refactor_spaces" {
  source  = "aws-ia/refactor-spaces/aws"
  version = "1.0.0"

  environment_name         = "Unicorn"
  environment_description  = "AWS Migration Hub Refactor Spaces environment for Unicorn Rentals."
  provision_network_bridge = true
  applications = [
    {
      application_name         = "Unistore"
      proxy_type               = "REGIONAL"
      application_proxy_vpc_id = "vpc-AAABBBBCCC"
      apigateway_stage_name    = "prod"
    }
  ]
  services = [
    {
      application_name = "Unistore"
      name             = "Unistore-legacy"
      description      = "The legacy monolithic application entry point"
      endpoint_type    = "URL"
      url_endpoint     = "http://www.example.com/"
      vpc_id           = "vpc-XXXYYYZZZ"
      routes = [
        {
          source_path  = "/"
          route_active = true
        }
      ]
    },
  }
}
```
The following example creates a new AWS Migration Hub Refactor Spaces service based on an AWS Lambda function and a route for `GET` and `POST` methods to the path `/unicorns/basket` in an existing AWS Migration Hub Refactor Spaces Application deployed in, or shared with the executing AWS Account:
```
module "refactor_spaces_microservice_x" {
  source  = "aws-ia/refactor-spaces/aws"
  version = "1.0.0"

  environment_id = "env-ab9ZXYVT9z"
  application_id = "app-xy1ABCDE1a"
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
          include_child_paths = true
          http_verbs          = ["POST", "GET"]
          route_active        = true
        }
      ]
    }
  ]
}
```
## Support & Feedback
This Terraform module is maintained by AWS Solution Architects. It is not part of an AWS service and support is provided best-effort by the community.

To post feedback, submit feature ideas, or report bugs, please use the Issues section of this GitHub repo.

## Contributing
Please see our [developer documentation](CONTRIBUTING.md) for guidance on contributing to this module.

## Known Issues

### Vpc Association Failed for Vpc with ID vpc-XXXYYYZZZ to environment with ID env-XXXYYYXZZ

**Issue:** During a `terraform apply` throw the following when deploying a the module with two (or more) AWS Migration Hub Refactor Spaces Applications defined (see below for example) the following exception is thrown:
```
Error: AWS SDK Go Service Operation Incomplete
│
│   with module.refactor_spaces_application["XXXX"].awscc_refactorspaces_application.current,
│   on modules\tf-refactor-spaces-application\main.tf line 13, in resource "awscc_refactorspaces_application" "current":
│   13: resource "awscc_refactorspaces_application" "current" {
│
│ Waiting for Cloud Control API service CreateResource operation completion returned: waiter state transitioned to FAILED. StatusMessage: java.lang.IllegalStateException: Resource of type AWS::RefactorSpaces::Application with identifier app-XXXXX did not stabilize. Details = ErrorResponse(AccountId=XXXXXXX, Code=RESOURCE_CREATION_FAILURE, Message=Vpc Association Failed for Vpc with ID vpc-XXXYYYZZZ to environment with ID env-XXXYYYXZZ., ResourceIdentifier=vpc-XXXYYYZZZ, ResourceType=VPC). ErrorCode: InternalFailure
```
Example configuration:
```
module "refactor_spaces" {
  source  = "aws-ia/refactor-spaces/aws"
  version = "1.0.0"

  environment_name        = "Unicorn"
  environment_description = "AWS Migration Hub Refactor Spaces environment for Unicorn Rentals."
  provision_network_bridge = true
  applications = [
    {
      application_name         = "Unistore"
      proxy_type               = "REGIONAL"
      application_proxy_vpc_id = "vpc-AAABBBBCCC"
      apigateway_stage_name    = "prod"
    },
    {
      application_name         = "Birds"
      proxy_type               = "REGIONAL"
      application_proxy_vpc_id = "vpc-DDDEEEFFF"
      apigateway_stage_name    = "prod"
    }
  ]
```
**Cause** This condition is caused as terraform attempts to create both Refactor Spaces Applications in asynchronously however concurrent creation/deletion of Application within the same AWS Migration Hub Refactor Spaces environment is not supported.   

**Workaround** Use the terraform [`-parallelism`](https://developer.hashicorp.com/terraform/cli/commands/apply#parallelism-n) flag set to `1` during the apply (e.g. `terraform apply -parallelism=1`) if creating multiple applications during a single apply or create the first application and perform the `terraform apply` and upon successful execution add the next application and re-run `terraform apply`.   

### Services forced recreation during every apply when using `awscc_refactorspaces_environment` or `awscc_refactorspaces_application` data objects in module input variables

**Issue:** When using the module to create AWS Migration Hub Refactor Spaces Services & Routes as separate module blocks and using the using the `awscc_refactorspaces_environment` or `awscc_refactorspaces_application` data objects as inputs terraform will create force re-creation (delete, create) during every apply.

**Cause** This is because the attributes `application_identifier` and `environment_identifier` will be marked as `(known after apply)` for the service and route resources which will force a replacement as these attributes are marked in the provider as a forced replacement operation.

**Workaround** Use input variables to define the values passed as `environment_id` and `application_id` to the module to prevent this behavior.  

### Defining multiple module blocks in the same HCL throws `Error: Invalid count argument`

**Issue:** When using the module to create AWS Migration Hub Refactor Spaces components as separate module blocks (e.g. one module block to create the environment, one module block to create an application and one module block to create services) in the same HCL which references the dependent module blocks, terraform throws:
```
 Error: Invalid count argument

   on .terraform\modules\XXXX\main.tf line 6, in module "XXX":
    6:   count = local.create_environment ? 1 : 0

The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created. To work around this, use the -target argument to first apply only the resources that the count depends on.
```
**Cause** The module uses count/foreach blocks to determine if an environment or application needs to be created. During a terraform plan, as the `environment_id` and/or `application_id` values are not known until after the apply, terraform throws an exception. Terraform currently has a limitation when using computed values in modules containing count and foreach blocks as the number of objects created must be known before the apply. (See https://github.com/hashicorp/terraform/issues/26078).

**Workaround** There are several approaches to workaround this issue such as:   
  1. If you wish to define multiple module blocks in a single HCL definition, use `terraform apply -target=module.XXX` to create the dependent modules first before calling `terraform apply`. You may have to execute several different `apply` actions with this approach or;
  2. Deploy each module blocks in different pipelines/projects/folders and read the remote state or use the relevant data objects to read the inputs

### In a multi-account deployment, service creation/deletion fails with Route Table operation failures if service tags removed from objects

**Issue:** In a multi-account deployment, service creation/deletion fails with a message similar to:
```
Waiting for Cloud Control API service CreateResource operation completion returned: waiter state transitioned to FAILED. StatusMessage: java.lang.IllegalStateException: Resource of type AWS::RefactorSpaces::Service
│ with identifier svc-XXXX did not stabilize. Details = ErrorResponse(AccountId=XXXX, AdditionalDetails={TransitGatewayID=tgw-XXXXX, DestinationCIDRBlock=XX.XX.XX.0/XX,
│ RouteTableID=rtb-XXXX}, Code=RESOURCE_UPDATE_FAILURE, Message=Failed to update Route table rtb-XXXXX to add route from CIDR XX.XX.XX.0/XX to TGW tgw-XXXX,
│ ResourceIdentifier=rtb-XXXXX, ResourceType=ROUTE_TABLE). ErrorCode: InternalFailure
```

**Cause** AWS Migration Hub Refactor Spaces service creates two tags `refactor-spaces:environment-id` and `refactor-spaces:application-id` on resources that are part of an environment during configuration. The table below provides a list of where each tag is configured as part of the service configuration.

These tags are used by the service and removal/adjustment can cause the service to behave incorrectly. In a multi-account deployment if these tags are removed from the resources this will cause the AWS Migration Services Refactor Spaces service operations to not complete successfully. This can occur if the objects are managed by AWS Config or Terraform with a configuration to have tags set explicitly to a set of values.

| Resource                                        | Tag(s)                         | Value                            |
|-------------------------------------------------|--------------------------------|----------------------------------|
| Environment Transit Gateway                     | refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Environment Resource Share                      | refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Application Amazon API Gateway                  | refactor-spaces:application-id | Refactor Spaces Application Id   |
| Network Load Balancer                           | refactor-spaces:application-id | Refactor Spaces Application Id   |
| Application Proxy VPC                           | refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Application Proxy VPC Subnet(s)                 | refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Application Proxy VPC Route Table(s)            | refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Application Proxy VPC Endpoint Service          | refactor-spaces:application-id | Refactor Spaces Application Id   |
| Application Proxy Refactor Spaces Security Group| refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Service Endpoint VPC                            | refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Service Endpoint VPC Subnet(s)                  | refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Service Endpoint VPC Route Table(s)             | refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Service Endpoint Transit GW Attachment          | refactor-spaces:environment-id | Refactor Spaces Environment Id   |
| Service Endpoint Refactor Spaces Security Group | refactor-spaces:environment-id | Refactor Spaces Environment Id   |

**Workaround** Any of these resources managed by Terraform (including those imported) should include these tags as part of the terraform resource definition or explicitly ignore them during applies.

For resources using the `aws` provider you can add the following to the provider configuration:
```
  ignore_tags {
    key_prefixes = ["refactor-spaces:"]
  }
```

For resources managed by the `awscc` provider you must add the tags to the resource definitions. A [feature request](https://github.com/hashicorp/terraform-provider-awscc/issues/800) has been opened to add this feature to the `awscc` provider in the future.

### Module Documentation

**Do not manually update README.md**. `terraform-docs` is used to generate README files. For any instructions an content, please update [.header.md](./.header.md) then simply run `terraform-docs ./` or allow the `pre-commit` to do so.

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.49.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc"></a> [awscc](#provider\_awscc) | >= 0.49.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_refactor_spaces_application"></a> [refactor\_spaces\_application](#module\_refactor\_spaces\_application) | ./modules/tf-refactor-spaces-application | n/a |
| <a name="module_refactor_spaces_environment"></a> [refactor\_spaces\_environment](#module\_refactor\_spaces\_environment) | ./modules/tf-refactor-spaces-environment | n/a |
| <a name="module_refactor_spaces_service_defaults"></a> [refactor\_spaces\_service\_defaults](#module\_refactor\_spaces\_service\_defaults) | ./modules/tf-refactor-spaces-service | n/a |
| <a name="module_refactor_spaces_service_non_defaults"></a> [refactor\_spaces\_service\_non\_defaults](#module\_refactor\_spaces\_service\_non\_defaults) | ./modules/tf-refactor-spaces-service | n/a |

## Resources

| Name | Type |
|------|------|
| [awscc_refactorspaces_application.application](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/refactorspaces_application) | data source |
| [awscc_refactorspaces_environment.environment](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/refactorspaces_environment) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | AWS Migration Hub Refactor Spaces Application id to use if not creating the application. | `string` | `null` | no |
| <a name="input_applications"></a> [applications](#input\_applications) | List of AWS Migration Hub Refactor Spaces applications to create. <br><br>Properties:<br>- `application_name`                       = (Required\|string) The name of the application<br>- `proxy_type`                             = (Optional\|string) The proxy type for the application. `REGIONAL` APIs are publicly accessible in the current Region. `PRIVATE` APIs are accessible only from VPCs. Default: REGIONAL.<br>- `apigateway_stage_name`                  = (Optional\|string) The name of the API Gateway stage to use for the application proxy. The name defaults to prod.<br>- `application_proxy_vpc_id`               = (Required\|string) The Amazon Virtual Private Cloud (VPC) id of VPC to deploy the application's proxy.<br><br>Example:<pre>applications = [<br>  {<br>    application_name         = "Unistore"<br>    proxy_type               = "PRIVATE"<br>    application_proxy_vpc_id = "vpc-XYZ"<br>    apigateway_stage_name    = "dev"<br>  },<br>  {<br>    application_name         = "Unistore-Prod"<br>    proxy_type               = "REGIONAL"<br>    application_proxy_vpc_id = "vpc-ABC"<br>    apigateway_stage_name    = "prod"<br>  }<br>]</pre> | <pre>list(object({<br>    application_name         = string<br>    proxy_type               = string<br>    apigateway_stage_name    = optional(string)<br>    application_proxy_vpc_id = string<br>  }))</pre> | `[]` | no |
| <a name="input_environment_description"></a> [environment\_description](#input\_environment\_description) | A description for the AWS Migration Hub Refactor Spaces environment (optional) | `string` | `null` | no |
| <a name="input_environment_id"></a> [environment\_id](#input\_environment\_id) | AWS Migration Hub Refactor Spaces Environment Id to use if not creating the Environment. | `string` | `null` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | The name of the AWS Migration Hub Refactor Spaces environment. Required if creating the environment. | `string` | `null` | no |
| <a name="input_provision_network_bridge"></a> [provision\_network\_bridge](#input\_provision\_network\_bridge) | When `true` AWS Migration Hub Refactor Spaces creates and manages an AWS Transit Gateway to establish cross account network connectivity for this environment. Default: false | `bool` | `false` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Tags to set for all resources | `map(string)` | `{}` | no |
| <a name="input_services"></a> [services](#input\_services) | List of AWS Migration Hub Refactor Spaces service specifications and their routing configuration. <br><br>Properties:<br>- `name`             = (Required\|string) The name of the service<br>- `application_name` = (Required\|string) The name of the application to associate the service<br>- `description`      = (Optional\|string) A description of the service<br>- `endpoint_type`    = (Required\|string) The endpoint type of the service; allowed type is `"URL"` or `"LAMBDA"`<br>- `lambda_arn`       = (Optional\|string) The Amazon Resource Name (ARN) of the Lambda function to use for the endpoint. Required if `endpoint_type = "LAMBDA"`<br>- `url_endpoint`     = (Optional\|string) The URL to route traffic to. The URL must be an rfc3986-formatted URL. If the host is a domain name, the name must be resolvable over the public internet. Required if `endpoint_type = "URL"`<br>- `health_url`       = (Optional\|string) The health check URL of the URL endpoint type. If the URL is a public endpoint, the HealthUrl must also be a public endpoint.<br>- `vpc_id`           = (Optional\|string) The ID of the virtual private cloud (VPC) hosting the URL to route traffic to.<br>- `routes`           = (Optional\|list(object)) A collection of routes to associate with the service.<br>  - `source_path`         = (Required\|string) (Required\|string) The path to use to match traffic. Paths must start with / and are relative to the base of the application. If the route is the default this should be set as '/'<br>  - `include_child_paths` = (Optional\|bool) Indicates whether to match all subpaths of the given source path. If this value is `false`, requests must match the source path exactly before they are forwarded to this route's service. Default true.<br>  - `http_verbs`          = (Optional\|list(string)) A list of HTTP methods to match. An empty list matches all values. Default all values.<br>  - `route_active`        = (Required\|bool) If set to `true`, traffic is forwarded to this route’s service after the route is created.<br><br>Example:<pre>services = [<br>  {<br>    name                                   = "Unistore-legacy"<br>    application_name                       = "Unistore"<br>    description                            = "The legacy monolithic application entry point"<br>    endpoint_type                          = "URL"<br>    url_endpoint                           = "http://legacy.example.com"<br>    vpc_id                                 = "vpc-XYZ"<br>    routes = [<br>      {<br>        source_path         = "/"     # Default route<br>        route_active        = true<br>      }<br>    ]<br>  },<br>  {<br>    name              = "Unistore-MicroServer"<br>    application_name  = "Unistore"<br>    description       = "The new Microservice"<br>    endpoint_type     = "LAMBDA"<br>    lambda_arn        = "arn:aws:lambda:us-east-1:123456789012:function:Test"<br>    routes = [<br>      {<br>        source_path         = "/unicorns/basket"<br>        include_child_paths = true<br>        http_verbs          = ["POST","GET"]<br>        route_active        = true<br>      }<br>    ]<br>  }<br>]</pre> | <pre>list(object({<br>    name             = string<br>    application_name = string<br>    description      = optional(string)<br>    endpoint_type    = string<br>    lambda_arn       = optional(string)<br>    url_endpoint     = optional(string)<br>    health_url       = optional(string)<br>    vpc_id           = optional(string)<br>    routes = optional(list(object({<br>      source_path         = string<br>      include_child_paths = optional(bool)<br>      http_verbs          = optional(list(string))<br>      route_active        = bool<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_shared_to_principals"></a> [shared\_to\_principals](#input\_shared\_to\_principals) | An optional list of AWS principals to share the AWS Migration Hub Refactor Spaces environment.<br><br>Please Note: The setting `Enable sharing with AWS Organizations` under the Resource Access Manager service must be enabled on the master account for your organization in order to share Organizational unit or to the entire Organization. See: https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html for further details.<br><br>Allowed values are: <br>- 12-digit AWS account ID's;<br>- ARN of the Organization or;<br>- ARN of the Organizational Units<br><br>Example:<pre>shared_to_principals = [<br>  "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-abcde01r",<br>  "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-rstuv02r",<br>]</pre> | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applications"></a> [applications](#output\_applications) | Collection of AWS Migration Hub Refactor Spaces Application managed by or used.<br><br>Example:<pre>applications = [<br>  {<br>    api_gateway_id = "a0abcdefg1o1"<br>    nlb_arn = "arn:aws:elasticloadbalancing:us-east-1:99999999999:loadbalancer/net/refactor-spaces-nlb-XXXX/YYYY",<br>    vpc_link_id = "00abcde"<br>    application = {<br>      "application_identifier" = "app-BSXbxAPn1r",<br>      "arn" = "arn:aws:refactor-spaces:us-east-1:627561228761:environment/env-ZoiD5hlRyz/application/app-BSXbxAPn1r",<br>      "environment_identifier" = "env-ZoiD5hlRyz",<br>      ...<br>            <all attributes of AWS Migration Hub Refactor Spaces Application: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_application><br>    }<br>    application_proxy_vpc_attributes = {<br>      <all attributes of the awscc_ec2_vpc data source: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/ec2_vpc><br>    }<br>  }<br>]</pre> |
| <a name="output_environment"></a> [environment](#output\_environment) | AWS Migration Hub Refactor Spaces environment resource attributes. Full output of [`awscc_refactorspaces_environment`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_environment) |
| <a name="output_services"></a> [services](#output\_services) | Collection of AWS Migration Hub Refactor Spaces Services and associated routes.<br><br>Example:<pre>services = [<br>  {<br>    "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/service/svc-XYZ"<br>    "name" = "legacy",<br>    description = "The legacy monolithic application entry point"<br>    routes = [<br>      {<br>        "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/route/rte-ABCD"<br>        "route_identifier" = "rte-ABCD"<br>        "route_type": "DEFAULT"<br>        ...<br>        <all attributes of AWS Migration Hub Refactor Spaces Route: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_route><br>      }<br>    ]<br>    ...<br>    <all attributes of AWS Migration Hub Refactor Spaces Service: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_service><br>  }<br>]</pre> |
<!-- END_TF_DOCS -->