<!-- BEGIN_TF_DOCS -->
# Terraform Module for AWS Migration Hub Refactor Spaces on AWS

## Overview

This module can be used to deploy [AWS Migration Hub Refactor Spaces](https://docs.aws.amazon.com/migrationhub-refactor-spaces/latest/userguide/what-is-mhub-refactor-spaces.html) components in the AWS Cloud. Common deployment examples can be found in [examples/](./examples). The module can be used to deploy Environments, Applications, Services & Routes or a subset of these resources to enable different use cases.

For more information, refer to the [AWS Migration Hub Refactor Space documentation](https://docs.aws.amazon.com/migrationhub/index.html).

## Table of contents

- [Overview](#overview)
- [Costs and licenses](#costs-and-licenses)
- [Architecture](#architecture)
- [Usage](#usage)
- [Support and Feedback](#support-and-feedback)
- [Contributing](#contributing)
- [Known Issues](#known-issues)
- [Module Documentation](#module-documentation)
- [Customer responsibility](#customer-responsibility)
- [Requirements](#requirements)
- [Providers](#providers)
- [Modules](#modules)
- [Resources](#resources)
- [Inputs](#inputs)
- [Outputs](#outputs)

## Costs and licenses

You pay for the cost of the Refactor Spaces feature and and any resources being consumed on AWS. For more information, refer to [AWS Migration Hub pricing](https://aws.amazon.com/migration-hub/pricing/).

## Architecture

The module can be used to create all AWS Migration Hub Refactor Spaces components as part of a single deployment or to add AWS Migration Hub Refactor Spaces applications or services to an existing AWS Migration Hub Refactor Spaces environment or application (for example in multi-account deployment scenarios).

Figure 1 shows an example deploying all AWS Migration Hub Refactor Spaces in a single account.

<p align="center">
  <img src="https://raw.githubusercontent.com/aws-ia/terraform-awscc-refactorspaces/main/images/aws_migration_hub_refactor_spaces_basic.png" alt="Simple" width="75%">
</p>

Figure 1. Example configuration of AWS Migration Hub Refactor Spaces deployed with a monolithic application 'Unishop' with a new AddToCart microservice running as a Lambda microservice.

As shown in the diagram, the module in this example sets up the following:

- An AWS Migration Hub Refactor Spaces environment with the *Provision a network bridge for cross account connectivity* option configured which creates a new AWS Transit Gateway managed by AWS Migration Hub Refactor Spaces
- An AWS Migration Hub Refactor Spaces application which creates an Amazon API Gateway
- A Network Load Balancer is deployed in a provided Amazon Virtual Private Cloud (VPC) and connected to the Amazon API Gateway by AWS Migration Hub Refactor Spaces using the VPC Link feature
- The following AWS Migration Hub Refactor Spaces services:
  - *Default* pointing to a monolithic application deployed on Amazon Elastic Compute Cloud (Amazon EC2). This service is acting as the default route for traffic.
  - *AddToCart* pointing at a microservice deployed as a Lambda Function *AddToCart* which holds the modernized AddToCart business logic.
  - A route that sends requests for the *AddToCart* domain to the Lambda function.

The following elements shown in the diagram are not deployed by the module but provided as [inputs](#inputs) and depicted to illustrate a real-world deployment scenario:

- A highly available architecture that spans two Availability Zones
- Two VPCs configured with private subnets
- An Amazon Virtual Private Cloud (VPC), deployed across two Availability Zones, used to host a Network Load Balancer deployed by AWS Migration Hub Refactor Spaces. This is used by the Amazon API Gateway to communicate with workloads deployed in other VPCs attached to the AWS Transit Gateway managed by AWS Migration Hub Refactor Spaces
- A second Amazon Virtual Private Cloud (VPC), deployed across two Availability Zones, used to host the monolithic application "Unistore legacy" attached to the AWS Transit Gateway managed by AWS Migration Hub Refactor Spaces
- In each of the private subnets of the second Amazon Virtual Private Cloud (VPC), an Amazon Elastic Compute Cloud (Amazon EC2) instance hosting the monolithic application "Unistore legacy"
- An Application Load Balancer, mapped two the private subnets of the second Amazon Virtual Private Cloud (VPC), forwarding traffic to a Target group containing the Amazon Elastic Compute Cloud (Amazon EC2) instances hosting the monolithic application "Unistore legacy"
- A Lambda Function *AddToCart* which holds the modernized AddToCart business logic that has been strangled from the "Unistore legacy" monolithic application

## Usage

For example usage, refer to the [examples/](./examples) directory in this repository.

## Support and Feedback

This Terraform module is maintained by AWS Solution Architects. It is not part of an AWS service and support is provided best-effort by the community.

To post feedback, submit feature ideas, or report bugs, please use the Issues section of this GitHub repo.

## Contributing

Please see our [developer documentation](CONTRIBUTING.md) for guidance on contributing to this module.

## Known Issues

### Vpc Association Failed for Vpc with ID vpc-XXXYYYZZZ to environment with ID env-XXXYYYXZZ

**Issue:** During a `terraform apply` throw the following when deploying a the module with two (or more) AWS Migration Hub Refactor Spaces Applications defined (see below for example) the following exception is thrown:

```log
Error: AWS SDK Go Service Operation Incomplete
│
│   with module.refactor_spaces_application["XXXX"].awscc_refactorspaces_application.current,
│   on modules\tf-refactor-spaces-application\main.tf line 13, in resource "awscc_refactorspaces_application" "current":
│   13: resource "awscc_refactorspaces_application" "current" {
│
│ Waiting for Cloud Control API service CreateResource operation completion returned: waiter state transitioned to FAILED. StatusMessage: java.lang.IllegalStateException: Resource of type AWS::RefactorSpaces::Application with identifier app-XXXXX did not stabilize. Details = ErrorResponse(AccountId=XXXXXXX, Code=RESOURCE_CREATION_FAILURE, Message=Vpc Association Failed for Vpc with ID vpc-XXXYYYZZZ to environment with ID env-XXXYYYXZZ., ResourceIdentifier=vpc-XXXYYYZZZ, ResourceType=VPC). ErrorCode: InternalFailure
```

Example configuration:

```hcl
module "refactor_spaces" {
  source  = "aws-ia/refactorspaces/awscc"
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

```log
 Error: Invalid count argument

   on .terraform\modules\XXXX\main.tf line 6, in module "XXX":
    6:   count = local.create_environment ? 1 : 0

The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created. To work around this, use the -target argument to first apply only the resources that the count depends on.
```

**Cause** The module uses count/foreach blocks to determine if an environment or application needs to be created. During a terraform plan, as the `environment_id` and/or `application_id` values are not known until after the apply, terraform throws an exception. Terraform currently has a limitation when using computed values in modules containing count and foreach blocks as the number of objects created must be known before the apply. (See <https://github.com/hashicorp/terraform/issues/26078>).

**Workaround** There are several approaches to workaround this issue such as:

  1. If you wish to define multiple module blocks in a single HCL definition, use `terraform apply -target=module.XXX` to create the dependent modules first before calling `terraform apply`. You may have to execute several different `apply` actions with this approach or;
  2. Deploy each module blocks in different pipelines/projects/folders and read the remote state or use the relevant data objects to read the inputs

### In a multi-account deployment, service creation/deletion fails with Route Table operation failures if service tags removed from objects

**Issue:** In a multi-account deployment, service creation/deletion fails with a message similar to:

```log
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

```hcl
  ignore_tags {
    key_prefixes = ["refactor-spaces:"]
  }
```

For resources managed by the `awscc` provider you must add the tags to the resource definitions. A [feature request](https://github.com/hashicorp/terraform-provider-awscc/issues/800) has been opened to add this feature to the `awscc` provider in the future.

### Module Documentation

**Do not manually update README.md**. `terraform-docs` is used to generate README files. For any instructions an content, please update [.header.md](./.header.md) then simply run `terraform-docs ./` or allow the `pre-commit` to do so.

## Customer responsibility

Cloud security at AWS is the highest priority. Security is a shared responsibility between AWS and you. For more information on understanding how to apply the shared responsibility model when using AWS Migration Hub Refactor Spaces, please refer to [Security in AWS Migration Hub Refactor Spaces](https://docs.aws.amazon.com/migrationhub-refactor-spaces/latest/userguide/security.html).

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
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
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | AWS Migration Hub Refactor Spaces application ID of an already-deployed application to deploy additional services. `var.environment_id` must be specified if this value is not `null`. | `string` | `null` | no |
| <a name="input_applications"></a> [applications](#input\_applications) | List of AWS Migration Hub Refactor Spaces applications to create. Ignored if `var.application_id` for an existing application is provided in the module block.<br><br>Properties:<br>- `application_name`                       = (Required\|string) The name of the application.<br>- `proxy_type`                             = (Optional\|string) The proxy type for the application. `REGIONAL` APIs are publicly accessible in the current Region. `PRIVATE` APIs are accessible only from VPCs. Default: REGIONAL.<br>- `apigateway_stage_name`                  = (Optional\|string) The name of the API Gateway stage to use for the application proxy. The name defaults to prod.<br>- `application_proxy_vpc_id`               = (Required\|string) The Amazon VPC ID of the VPC to deploy the application's proxy.<br><br>Example:<pre>applications = [<br>  {<br>    application_name         = "Unistore"<br>    proxy_type               = "PRIVATE"<br>    application_proxy_vpc_id = "vpc-XYZ"<br>    apigateway_stage_name    = "dev"<br>  },<br>  {<br>    application_name         = "Unistore-Prod"<br>    proxy_type               = "REGIONAL"<br>    application_proxy_vpc_id = "vpc-ABC"<br>    apigateway_stage_name    = "prod"<br>  }<br>]</pre> | <pre>list(object({<br>    application_name         = string<br>    proxy_type               = string<br>    apigateway_stage_name    = optional(string)<br>    application_proxy_vpc_id = string<br>  }))</pre> | `[]` | no |
| <a name="input_environment_description"></a> [environment\_description](#input\_environment\_description) | (Optional) Description for the AWS Migration Hub Refactor Spaces environment. Ignored if `var.environment_id` for an existing environment is provided. | `string` | `null` | no |
| <a name="input_environment_id"></a> [environment\_id](#input\_environment\_id) | AWS Migration Hub Refactor Spaces Environment ID of an already-deployed environment to deploy additional applications or services. | `string` | `null` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of the AWS Migration Hub Refactor Spaces environment to create. Ignored if `var.environment_id` for an existing environment is provided. | `string` | `null` | no |
| <a name="input_provision_network_bridge"></a> [provision\_network\_bridge](#input\_provision\_network\_bridge) | When `true` AWS Migration Hub Refactor Spaces creates and manages an AWS Transit Gateway to establish cross account network connectivity for this environment. Default: false. | `bool` | `false` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Tags to set for all resources. | `map(string)` | `{}` | no |
| <a name="input_services"></a> [services](#input\_services) | List of AWS Migration Hub Refactor Spaces service specifications and their routing configuration.<br><br>Properties:<br>- `name`             = (Required\|string) The name of the service.<br>- `application_name` = (Required\|string) The name of the application to associate the service.<br>- `description`      = (Optional\|string) A description of the service.<br>- `endpoint_type`    = (Required\|string) The endpoint type of the service. Allowed type is `"URL"` or `"LAMBDA"`.<br>- `lambda_arn`       = (Optional\|string) The ARN of the Lambda function to use for the endpoint. Required if `endpoint_type = "LAMBDA"`.<br>- `url_endpoint`     = (Optional\|string) The URL to route traffic to. The URL must be an rfc3986-formatted URL. If the host is a domain name, the name must be resolvable over the public internet. Required if `endpoint_type = "URL"`.<br>- `health_url`       = (Optional\|string) The health check URL of the URL endpoint type. If the URL is a public endpoint, the HealthURL must also be a public endpoint.<br>- `vpc_id`           = (Optional\|string) The ID of the VPC hosting the URL to route traffic to.<br>- `routes`           = (Optional\|list(object)) A collection of routes to associate with the service.<br>  - `source_path`         = (Required\|string) (Required\|string) The path to use to match traffic. Paths must start with / and are relative to the base of the application. If the route is the default this should be set as '/'.<br>  - `include_child_paths` = (Optional\|bool) Indicates whether to match all subpaths of the given source path. If this value is `false`, requests must match the source path exactly before they are forwarded to this route's service. Default true.<br>  - `http_verbs`          = (Optional\|list(string)) A list of HTTP methods to match. An empty list matches all values. Default all values.<br>  - `route_active`        = (Required\|bool) If set to `true`, traffic is forwarded to this route’s service after the route is created.<br><br>Example:<pre>services = [<br>  {<br>    name                                   = "Unistore-legacy"<br>    application_name                       = "Unistore"<br>    description                            = "The legacy monolithic application entry point"<br>    endpoint_type                          = "URL"<br>    url_endpoint                           = "http://legacy.example.com"<br>    vpc_id                                 = "vpc-XYZ"<br>    routes = [<br>      {<br>        source_path         = "/"     # Default route<br>        route_active        = true<br>      }<br>    ]<br>  },<br>  {<br>    name              = "Unistore-MicroServer"<br>    application_name  = "Unistore"<br>    description       = "The new Microservice"<br>    endpoint_type     = "LAMBDA"<br>    lambda_arn        = "arn:aws:lambda:us-east-1:123456789012:function:Test"<br>    routes = [<br>      {<br>        source_path         = "/unicorns/basket"<br>        include_child_paths = true<br>        http_verbs          = ["POST","GET"]<br>        route_active        = true<br>      }<br>    ]<br>  }<br>]</pre> | <pre>list(object({<br>    name             = string<br>    application_name = string<br>    description      = optional(string)<br>    endpoint_type    = string<br>    lambda_arn       = optional(string)<br>    url_endpoint     = optional(string)<br>    health_url       = optional(string)<br>    vpc_id           = optional(string)<br>    routes = optional(list(object({<br>      source_path         = string<br>      include_child_paths = optional(bool)<br>      http_verbs          = optional(list(string))<br>      route_active        = bool<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_shared_to_principals"></a> [shared\_to\_principals](#input\_shared\_to\_principals) | Optional list of AWS principals to share the AWS Migration Hub Refactor Spaces environment. Ignored if `var.environment_id` for an existing environment is provided.<br><br>Please Note: The setting `Enable sharing with AWS Organizations` under the Resource Access Manager service must be enabled on the master account for your organization to share the organizational unit or to share with the entire organization. For more information, see https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html.<br><br>Allowed values are:<br>- 12-digit AWS account IDs;<br>- ARN of the organization or;<br>- ARN of the organizational units<br><br>Example:<pre>shared_to_principals = [<br>  "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-abcde01r",<br>  "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-rstuv02r",<br>]</pre> | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applications"></a> [applications](#output\_applications) | Collection of AWS Migration Hub Refactor Spaces application managed by or used.<br><br>Example:<pre>applications = [<br>  {<br>    api_gateway_id = "a0abcdefg1o1"<br>    nlb_arn = "arn:aws:elasticloadbalancing:us-east-1:99999999999:loadbalancer/net/refactor-spaces-nlb-XXXX/YYYY",<br>    vpc_link_id = "00abcde"<br>    application = {<br>      "application_identifier" = "app-BSXbxAPn1r",<br>      "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ZoiD5hlRyz/application/app-BSXbxAPn1r",<br>      "environment_identifier" = "env-ZoiD5hlRyz",<br>      ...<br>            <all attributes of AWS Migration Hub Refactor Spaces Application: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_application><br>    }<br>    application_proxy_vpc_attributes = {<br>      <all attributes of the awscc_ec2_vpc data source: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/ec2_vpc><br>    }<br>  }<br>]</pre> |
| <a name="output_environment"></a> [environment](#output\_environment) | AWS Migration Hub Refactor Spaces environment resource attributes. Full output of [`awscc_refactorspaces_environment`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_environment). |
| <a name="output_services"></a> [services](#output\_services) | Collection of AWS Migration Hub Refactor Spaces services and associated routes.<br><br>Example:<pre>services = [<br>  {<br>    "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/service/svc-XYZ"<br>    "name" = "legacy",<br>    description = "The legacy monolithic application entry point"<br>    routes = [<br>      {<br>        "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/route/rte-ABCD"<br>        "route_identifier" = "rte-ABCD"<br>        "route_type": "DEFAULT"<br>        ...<br>        <all attributes of AWS Migration Hub Refactor Spaces Route: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_route><br>      }<br>    ]<br>    ...<br>    <all attributes of AWS Migration Hub Refactor Spaces Service: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_service><br>  }<br>]</pre> |
<!-- END_TF_DOCS -->