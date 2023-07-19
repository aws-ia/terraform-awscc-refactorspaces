<!-- BEGIN_TF_DOCS -->
# Terraform Module for AWS Migration Hub Refactor Spaces on AWS

## Overview

This Amazon Web Services (AWS) Solution is used to deploy [AWS Migration Hub Refactor Spaces](https://docs.aws.amazon.com/migrationhub-refactor-spaces/latest/userguide/what-is-mhub-refactor-spaces.html) components in the AWS Cloud. For common deployment examples, refer to [examples/](https://github.com/aws-ia/terraform-awscc-refactorspaces/tree/main/examples). The solution is for users who want to deploy Refactor Spaces environments and modernize applications to microservices. Refactor Spaces helps reduce the undifferentiated heavy lifting of building and operating AWS infrastructure for incremental refactoring.

For more information, refer to the [AWS Migration Hub Refactor Space documentation](https://docs.aws.amazon.com/migrationhub/index.html).

## Costs and licenses

You pay for the cost of the Refactor Spaces feature and any resources being consumed on AWS. For more information, refer to [AWS Migration Hub pricing](https://aws.amazon.com/migration-hub/pricing/).

## Architecture

Use this solution to create all AWS Migration Hub Refactor Spaces components as part of a single deployment or to add AWS Migration Hub Refactor Spaces applications or services to an existing AWS Migration Hub Refactor Spaces environment or application (in multi-account deployment scenarios).

Figure 1 shows an example deployment of all AWS Migration Hub Refactor Spaces in a single account.

![Architecture for Migration Hub Refactor Spaces on AWS](https://raw.githubusercontent.com/aws-ia/terraform-awscc-refactorspaces/main/images/aws_migration_hub_refactor_spaces_basic.png)

Figure 1. Example configuration of AWS Migration Hub Refactor Spaces deployed with a monolithic application Unishop with a new AddToCart microservice, running as an AWS Lambda microservice.

As shown in the diagram, the solution in this example sets up the following:

* A highly available architecture that spans two Availability Zones.*
* In one virtual private cloud (VPC):
  * Private subnets containing an AWS Transit Gateway attachment. Amazon API Gateway uses this attachment to communicate with workloads deployed in other AWS accounts/VPCs.*
  * A Network Load Balancer, which uses the VPC link feature and distributes incoming traffic.*
* In the second VPC:
  * Private subnets, which contain an Amazon Elastic Compute Cloud (Amazon EC2) instance that hosts the monolithic Unistore legacy application. Each subnet also contains an AWS Transit Gateway attachment, which is used to provide private connectivity between the API Gateway and the application hosted within the VPC.*
  * An Application Load Balancer to forward traffic to the Amazon EC2 instances.*
* In the AWS Migration Hub's Refactor Spaces environment:
  * AWS Transit Gateway, provisioned and managed by AWS Migration Hub's Refactor Spaces. If you choose to bring your own AWS Transit Gateway, this can be controlled using an optional input parameter.
  * A Refactor Spaces application that manages Amazon API Gateway and two services: Default and AddtoCart. Default acts as the default route for traffic to the Unistore application. AddtoCart sends AddtoCart domain requests to the AWS Lambda function.
* A Lambda function that holds the modernized AddToCart business logic strangled from the Unistore application.

*The Terraform module that deploys this solution does not include the components marked by asterisks. These components, which you would provide as inputs, are depicted to illustrate a real-world deployment scenario.

## Usage

For example usage, refer to the [examples/](https://github.com/aws-ia/terraform-awscc-refactorspaces/tree/main/examples) directory in this repository.

## Support and Feedback

This Terraform solution is maintained by AWS Solution Architects. It is not part of an AWS service, so the community provides support.

To post feedback, submit feature ideas, or report bugs, use the Issues section of this GitHub repo.

## Contributing

Refer to our [developer documentation](CONTRIBUTING.md) for guidance on contributing to this solution.

## Known Issues

### The VPC association failed for a VPC with a vpc-XXXYYYZZZ ID to an environment with a env-XXXYYYXZZ ID

**Issue:** During a `terraform apply`, when you deploy a solution with two or more AWS Migration Hub Refactor Spaces applications defined (see below for example), you encounter the following exception:

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
  version = "0.0.2"

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

**Cause:** Terraform attempts to create both Refactor Spaces applications asynchronously; however, concurrent creation/deletion of an application within the same AWS Migration Hub Refactor Spaces environment is not supported.

**Workaround:** If you are creating multiple applications during a single apply, use the Terraform [`-parallelism`](https://developer.hashicorp.com/terraform/cli/commands/apply#parallelism-n) flag set to `1` (example: `terraform apply -parallelism=1`). You can also create the first application and perform the `terraform apply` and after execution, add the next application and re-run `terraform apply`.

### The services forced recreation during every apply when using `awscc_refactorspaces_environment` or `awscc_refactorspaces_application` data objects in the module input variables

**Issue:** When using the solution to create AWS Migration Hub Refactor Spaces services and routes as separate module blocks, and using the `awscc_refactorspaces_environment` or `awscc_refactorspaces_application` data objects as inputs, Terraform forces a re-creation (delete, create) during every apply.

**Cause:** The attributes `application_identifier` and `environment_identifier` are marked as `(known after apply)` for the service and route resources. This forces a replacement because these attributes are marked in the provider as a forced replacement operation.

**Workaround:** Use input variables to define the values passed as `environment_id` and `application_id` to the module.

### Defining multiple module blocks in the same HCL causes this error: `Error: Invalid count argument`

**Issue:** When using the solution to create AWS Migration Hub Refactor Spaces components as separate module blocks (one module block to create the environment, one module block to create an application, and one module block to create services) in the same HCL which references the dependent module blocks, you encounter this error:

```log
 Error: Invalid count argument

   on .terraform\modules\XXXX\main.tf line 6, in module "XXX":
    6:   count = local.create_environment ? 1 : 0

The "count" value depends on resource attributes that cannot be determined until apply, so Terraform cannot predict how many instances will be created. To work around this, use the -target argument to first apply only the resources that the count depends on.
```

**Cause:** The module uses count/foreach blocks to determine if an environment or application needs to be created. During a Terraform plan, as the `environment_id` and/or `application_id` values are not known until after the apply, Terraform encounters an exception. Terraform currently has a limitation when using computed values in modules containing count and foreach blocks, so the number of objects created must be known before the apply. (See <https://github.com/hashicorp/terraform/issues/26078>).

**Workaround:** Use one of the following approaches to workaround this issue:

  1. If you wish to define multiple module blocks in a single HCL definition, use `terraform apply -target=module.XXX` to create the dependent modules first before calling `terraform apply`. You may have to execute several different `apply` actions with this approach.
  2. Deploy each module blocks in different pipelines/projects/folders and read the remote state, or use the relevant data objects to read the inputs.

### In a multi-account deployment, service creation/deletion fails with Route Table operation failures, if service tags are removed from objects

**Issue:** You receive a failure message similar to the following:

```log
Waiting for Cloud Control API service CreateResource operation completion returned: waiter state transitioned to FAILED. StatusMessage: java.lang.IllegalStateException: Resource of type AWS::RefactorSpaces::Service
│ with identifier svc-XXXX did not stabilize. Details = ErrorResponse(AccountId=XXXX, AdditionalDetails={TransitGatewayID=tgw-XXXXX, DestinationCIDRBlock=XX.XX.XX.0/XX,
│ RouteTableID=rtb-XXXX}, Code=RESOURCE_UPDATE_FAILURE, Message=Failed to update Route table rtb-XXXXX to add route from CIDR XX.XX.XX.0/XX to TGW tgw-XXXX,
│ ResourceIdentifier=rtb-XXXXX, ResourceType=ROUTE_TABLE). ErrorCode: InternalFailure
```

**Cause:** AWS Migration Hub Refactor Spaces service creates the tags `refactor-spaces:environment-id` and `refactor-spaces:application-id` on resources that are part of an environment during configuration. The table below provides a list of where each tag is configured as part of the service configuration.

These tags are used by the service and removal/adjustment can cause the service to behave incorrectly. In a multi-account deployment, if these tags are removed from the resources, it causes the AWS Migration Services Refactor Spaces service operations to complete unsuccessfully. This can occur if the objects are managed by AWS Config or Terraform with a configuration to have tags set explicitly to a set of values.

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

**Workaround:** Any of these resources managed by Terraform (including those imported) should include these tags as part of the Terraform resource definition, or explicitly ignore them during applies.

For resources using the `aws` provider, add the following to the provider configuration:

```hcl
  ignore_tags {
    key_prefixes = ["refactor-spaces:"]
  }
```

For resources managed by the `awscc` provider you must add the tags to the resource definitions. A [feature request](https://github.com/hashicorp/terraform-provider-awscc/issues/800) has been opened to add this feature to the `awscc` provider, in the future.

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
| <a name="input_environment_description"></a> [environment\_description](#input\_environment\_description) | (Optional) Description for AWS Migration Hub Refactor Spaces environment. Ignored if `var.environment_id` for an existing environment is provided. | `string` | `null` | no |
| <a name="input_environment_id"></a> [environment\_id](#input\_environment\_id) | AWS Migration Hub Refactor Spaces environment ID of an already-deployed environment to deploy additional applications or services. | `string` | `null` | no |
| <a name="input_environment_name"></a> [environment\_name](#input\_environment\_name) | Name of AWS Migration Hub Refactor Spaces environment to create. Ignored if `var.environment_id` for an existing environment is provided. | `string` | `null` | no |
| <a name="input_provision_network_bridge"></a> [provision\_network\_bridge](#input\_provision\_network\_bridge) | When `true` AWS Migration Hub Refactor Spaces creates and manages an AWS Transit Gateway to establish cross-account network connectivity for this environment. Default: false. | `bool` | `false` | no |
| <a name="input_resource_tags"></a> [resource\_tags](#input\_resource\_tags) | Tags to set for all resources. | `map(string)` | `{}` | no |
| <a name="input_services"></a> [services](#input\_services) | List of AWS Migration Hub Refactor Spaces service specifications and their routing configuration.<br><br>Properties:<br>- `name`             = (Required\|string) The name of the service.<br>- `application_name` = (Required\|string) The name of the application to associate the service.<br>- `description`      = (Optional\|string) A description of the service.<br>- `endpoint_type`    = (Required\|string) The endpoint type of the service. Allowed type is `"URL"` or `"LAMBDA"`.<br>- `lambda_arn`       = (Optional\|string) The ARN of the Lambda function to use for the endpoint. Required if `endpoint_type = "LAMBDA"`.<br>- `url_endpoint`     = (Optional\|string) The URL to route traffic to. The URL must be an rfc3986-formatted URL. If the host is a domain name, the name must be resolvable over the public internet. Required if `endpoint_type = "URL"`.<br>- `health_url`       = (Optional\|string) The health check URL of the URL endpoint type. If the URL is a public endpoint, the HealthURL must also be a public endpoint.<br>- `vpc_id`           = (Optional\|string) The ID of the VPC hosting the URL to route traffic to.<br>- `routes`           = (Optional\|list(object)) A collection of routes to associate with the service.<br>  - `source_path`         = (Required\|string) (Required\|string) The path to use to match traffic. Paths must start with / and are relative to the base of the application. If the route is the default this should be set as '/'.<br>  - `include_child_paths` = (Optional\|bool) Indicates whether to match all subpaths of the given source path. If this value is `false`, requests must match the source path exactly before they are forwarded to this route's service. Default true.<br>  - `http_verbs`          = (Optional\|list(string)) A list of HTTP methods to match. An empty list matches all values. Default all values.<br>  - `route_active`        = (Required\|bool) If set to `true`, traffic is forwarded to this route’s service after the route is created.<br><br>Example:<pre>services = [<br>  {<br>    name                                   = "Unistore-legacy"<br>    application_name                       = "Unistore"<br>    description                            = "The legacy monolithic application entry point"<br>    endpoint_type                          = "URL"<br>    url_endpoint                           = "http://legacy.example.com"<br>    vpc_id                                 = "vpc-XYZ"<br>    routes = [<br>      {<br>        source_path         = "/"     # Default route<br>        route_active        = true<br>      }<br>    ]<br>  },<br>  {<br>    name              = "Unistore-MicroServer"<br>    application_name  = "Unistore"<br>    description       = "The new Microservice"<br>    endpoint_type     = "LAMBDA"<br>    lambda_arn        = "arn:aws:lambda:us-east-1:123456789012:function:Test"<br>    routes = [<br>      {<br>        source_path         = "/unicorns/basket"<br>        include_child_paths = true<br>        http_verbs          = ["POST","GET"]<br>        route_active        = true<br>      }<br>    ]<br>  }<br>]</pre> | <pre>list(object({<br>    name             = string<br>    application_name = string<br>    description      = optional(string)<br>    endpoint_type    = string<br>    lambda_arn       = optional(string)<br>    url_endpoint     = optional(string)<br>    health_url       = optional(string)<br>    vpc_id           = optional(string)<br>    routes = optional(list(object({<br>      source_path         = string<br>      include_child_paths = optional(bool)<br>      http_verbs          = optional(list(string))<br>      route_active        = bool<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_shared_to_principals"></a> [shared\_to\_principals](#input\_shared\_to\_principals) | Optional list of AWS principals to share the AWS Migration Hub Refactor Spaces environment with. Ignored if `var.environment_id` for an existing environment is provided.<br><br>Note: The setting `Enable sharing with AWS Organizations` under the Resource Access Manager service must be enabled on the master account for your organization to share the organizational unit or to share with the entire organization. For more information, refer to https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html.<br><br>Allowed values are:<br>- 12-digit AWS account IDs;<br>- ARN of the organization or;<br>- ARN of the organizational units<br><br>Example:<pre>shared_to_principals = [<br>  "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-abcde01r",<br>  "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-rstuv02r",<br>]</pre> | `list(string)` | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applications"></a> [applications](#output\_applications) | Collection of AWS Migration Hub Refactor Spaces application managed by or used.<br><br>Example:<pre>applications = [<br>  {<br>    api_gateway_id = "a0abcdefg1o1"<br>    nlb_arn = "arn:aws:elasticloadbalancing:us-east-1:99999999999:loadbalancer/net/refactor-spaces-nlb-XXXX/YYYY",<br>    vpc_link_id = "00abcde"<br>    application = {<br>      "application_identifier" = "app-BSXbxAPn1r",<br>      "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ZoiD5hlRyz/application/app-BSXbxAPn1r",<br>      "environment_identifier" = "env-ZoiD5hlRyz",<br>      ...<br>            <all attributes of AWS Migration Hub Refactor Spaces Application: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_application><br>    }<br>    application_proxy_vpc_attributes = {<br>      <all attributes of the awscc_ec2_vpc data source: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/ec2_vpc><br>    }<br>  }<br>]</pre> |
| <a name="output_environment"></a> [environment](#output\_environment) | AWS Migration Hub Refactor Spaces environment resource attributes. Full output of [`awscc_refactorspaces_environment`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_environment). |
| <a name="output_services"></a> [services](#output\_services) | Collection of AWS Migration Hub Refactor Spaces services and associated routes.<br><br>Example:<pre>services = [<br>  {<br>    "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/service/svc-XYZ"<br>    "name" = "legacy",<br>    description = "The legacy monolithic application entry point"<br>    routes = [<br>      {<br>        "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/route/rte-ABCD"<br>        "route_identifier" = "rte-ABCD"<br>        "route_type": "DEFAULT"<br>        ...<br>        <all attributes of AWS Migration Hub Refactor Spaces Route: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_route><br>      }<br>    ]<br>    ...<br>    <all attributes of AWS Migration Hub Refactor Spaces Service: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_service><br>  }<br>]</pre> |
<!-- END_TF_DOCS -->