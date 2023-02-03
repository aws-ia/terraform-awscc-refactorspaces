<!-- BEGIN_TF_DOCS -->
# Example : Deploying and configuring AWS Migration Hub Refactor Spaces in a multi-account

The following example deploys AWS Migration Hub Refactor Spaces components in a multi-account setup. In this example the components are deployed according to separation of concerns. In the example the CI/CD pipeline deploying the components would be executing in a single pipeline account however this could be decomposed with the pipeline for each application deploying the application and associated services/routes.

This approach simplifies implementation of least-privilege access models for a single application scope, simplify internal resource tracking and charge-back and service limits and quotas.

This example would deploy the following:
* An Amazon VPC "vpc-application-example-proxy" with IPv4 CIDR 192.168.10.0/24 and two 27-bit private subnets
* A AWS Migration Hub Refactor Spaces environment named "unicorn-dev" (in the `central-mgmt` account)
* A AWS Migration Hub Refactor Spaces application named "Unistore" (in the `unistore-frontend` account)
* A AWS Migration Hub Refactor Spaces service "Unistore-legacy" pointing to a monolithic application deployed on Amazon EC2/ECS/EKS or similar services running in a VPC with a DNS name `http://legacy-unicorns.example.com/` acting as the default route (in the `unistore-frontend` account)
* A AWS Migration Hub Refactor Spaces service "Unistore-AddToCartService" pointing at a microservice deployed as AWS Lambda Function with the ARN `arn:aws:lambda:us-east-1:999999999999:function:AddToCart`. (in the `unistore-userservice` account)
* A route that sends `POST` and `GET` requests to `/unicorns/basket` to the AWS Lambda function (in the `unistore-userservice` account)

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.0.0, < 5.0.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.35.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_awscc.central-mgmt"></a> [awscc.central-mgmt](#provider\_awscc.central-mgmt) | >= 0.35.0 |
| <a name="provider_awscc.unistore-frontend"></a> [awscc.unistore-frontend](#provider\_awscc.unistore-frontend) | >= 0.35.0 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_refactor_spaces_app_proxy_vpc"></a> [refactor\_spaces\_app\_proxy\_vpc](#module\_refactor\_spaces\_app\_proxy\_vpc) | aws-ia/vpc/aws | 3.1.0 |
| <a name="module_refactor_spaces_application_unishop"></a> [refactor\_spaces\_application\_unishop](#module\_refactor\_spaces\_application\_unishop) | ../../ | n/a |
| <a name="module_refactor_spaces_environment"></a> [refactor\_spaces\_environment](#module\_refactor\_spaces\_environment) | ../../ | n/a |
| <a name="module_refactor_spaces_unishop_add_cart"></a> [refactor\_spaces\_unishop\_add\_cart](#module\_refactor\_spaces\_unishop\_add\_cart) | ../../ | n/a |
| <a name="module_refactor_spaces_unishop_monolith"></a> [refactor\_spaces\_unishop\_monolith](#module\_refactor\_spaces\_unishop\_monolith) | ../../ | n/a |

## Resources

| Name | Type |
|------|------|
| [awscc_refactorspaces_application.unistore](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/refactorspaces_application) | data source |
| [awscc_refactorspaces_environment.unicorns](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/refactorspaces_environment) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_aws_provider_profile_central_management"></a> [aws\_provider\_profile\_central\_management](#input\_aws\_provider\_profile\_central\_management) | The AWS profile name defined in the shared configuration file (~/.aws/config) to use for the Refactor Spaces Environment. | `string` | `null` | no |
| <a name="input_aws_provider_profile_microservice_usermgmt"></a> [aws\_provider\_profile\_microservice\_usermgmt](#input\_aws\_provider\_profile\_microservice\_usermgmt) | The AWS profile name defined in the shared configuration file (~/.aws/config) to use for the User Management microservices | `string` | `null` | no |
| <a name="input_aws_provider_profile_mod_frontend"></a> [aws\_provider\_profile\_mod\_frontend](#input\_aws\_provider\_profile\_mod\_frontend) | The AWS profile name defined in the shared configuration file (~/.aws/config) to use for the modernized front-end (S3, CloudFront, Refactor Spaces Application). | `string` | `null` | no |
| <a name="input_aws_region"></a> [aws\_region](#input\_aws\_region) | The AWS region to deploy all resources. | `string` | `"us-east-1"` | no |
| <a name="input_aws_shared_config_file_path"></a> [aws\_shared\_config\_file\_path](#input\_aws\_shared\_config\_file\_path) | Full path to the AWS Config file (~/.aws/config) to use for AWS profile configuration. Required if using multi-account deployment. | `string` | `null` | no |
| <a name="input_aws_shared_credentials_file_path"></a> [aws\_shared\_credentials\_file\_path](#input\_aws\_shared\_credentials\_file\_path) | Full path to the AWS Credential file (~/.aws/credential) to use for AWS profile configuration. Required if using multi-account deployment. | `string` | `null` | no |
| <a name="input_unistore_modernized_principals"></a> [unistore\_modernized\_principals](#input\_unistore\_modernized\_principals) | A list of AWS principals to share the Refactor Spaces environment.<br><br>Please Note: The setting `Enable sharing with AWS Organizations` under the Resource Access Manager service must be enabled on the master account for your organization in order to share Organizational unit or to the entire Organization. See: https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html for further details.<br><br>Allowed values are: <br>- 12-digit AWS account ID's;<br>- ARN of the Organization or;<br>- ARN of the Organizational Units<br><br>Example:<pre>unistore_modernized_principals = [<br>  "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-abcde01r",<br>  "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-rstuv02r",<br>]</pre> | `list(string)` | `[]` | no |
| <a name="input_unistore_modernized_proxy_vpc_cidr"></a> [unistore\_modernized\_proxy\_vpc\_cidr](#input\_unistore\_modernized\_proxy\_vpc\_cidr) | A CIDR for a VPC provisioned to host the strangler-fig proxy for the modern application | `string` | `"192.168.200.0/24"` | no |

## Outputs

No outputs.
<!-- END_TF_DOCS -->