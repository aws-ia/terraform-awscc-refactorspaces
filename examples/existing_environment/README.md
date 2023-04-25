<!-- BEGIN_TF_DOCS -->

# Example : Deploy a Microservice to an existing shared Application

The following example creates a new AWS Migration Hub Refactor Spaces service based on an AWS Lambda function and a route for `GET` and `POST` methods to the path `/unicorns/reviews` in an existing AWS Migration Hub Refactor Spaces Application deployed in, or shared with the executing AWS Account. Use case for this would be to deploy Environment and application in separate CI/CD pipelines and deploy the Service as part of the microservice CI/CD pipeline in a separate account.

This example would deploy the following:

* A AWS Migration Hub Refactor Spaces service "Unistore-AddReview" pointing at a microservice deployed as AWS Lambda Function with the ARN `arn:aws:lambda:us-east-1:999999999999:function:AddReview` in an existing AWS Migration Hub Refactor Spaces application shared with the Account with the id `app-xy1ABCDE1a` in the environment `env-ab9ZXYVT9z`.
* A route that sends `POST` and `GET` requests to `/unicorns/reviews` to the AWS Lambda function

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_awscc"></a> [awscc](#requirement\_awscc) | >= 0.49.0 |

## Providers

No providers.

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_refactor_spaces_microservice_x"></a> [refactor\_spaces\_microservice\_x](#module\_refactor\_spaces\_microservice\_x) | aws-ia/refactorspaces/awscc | 0.1.0 |

## Resources

No resources.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_application_id"></a> [application\_id](#input\_application\_id) | AWS Migration Hub Refactor Spaces Application id of the deployed application to configure the new microservice. | `string` | `"app-xy1ABCDE1a"` | no |
| <a name="input_application_name"></a> [application\_name](#input\_application\_name) | The display name of an existing AWS Migration Hub Refactor Spaces application to add the microservice. | `string` | `"Unistore"` | no |
| <a name="input_description_lambda_microservice"></a> [description\_lambda\_microservice](#input\_description\_lambda\_microservice) | A description for the the Lambda based microservice to add to an existing AWS Migration Hub Refactor Spaces application. | `string` | `"The new AddToCart Microservice"` | no |
| <a name="input_display_name_lambda_microservice"></a> [display\_name\_lambda\_microservice](#input\_display\_name\_lambda\_microservice) | A display name for a new Lambda based microservice to add to an existing AWS Migration Hub Refactor Spaces application to strangle a function of the monolith. | `string` | `"Unistore-AddReview"` | no |
| <a name="input_environment_id"></a> [environment\_id](#input\_environment\_id) | AWS Migration Hub Refactor Spaces Environment Id of an already deployed environment to use to deploy the new microservice. | `string` | `"env-ab9ZXYVT9z"` | no |
| <a name="input_http_verbs_lambda_microservice"></a> [http\_verbs\_lambda\_microservice](#input\_http\_verbs\_lambda\_microservice) | A list of HTTP methods AWS Migration Hub Refactor Spaces will use to to match traffic destined for the new microservice. | `string` | <pre>[<br>  "POST",<br>  "GET"<br>]</pre> | no |
| <a name="input_lambda_arn_microservice"></a> [lambda\_arn\_microservice](#input\_lambda\_arn\_microservice) | The Amazon Resource Name (ARN) of the Lambda function to use as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith. | `string` | `"arn:aws:lambda:us-east-1:999999999999:function:AddReview"` | no |
| <a name="input_source_path_lambda_microservice"></a> [source\_path\_lambda\_microservice](#input\_source\_path\_lambda\_microservice) | The path AWS Migration Hub Refactor Spaces will use to match traffic destined for the new microservice. Paths must start with / and are relative to the base of the application. | `string` | `"/unicorns/reviews"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_applications"></a> [applications](#output\_applications) | Collection of AWS Migration Hub Refactor Spaces Application managed by or used.<br><br>Example:<pre>applications = [<br>  {<br>    api_gateway_id = "a0abcdefg1o1"<br>    nlb_arn = "arn:aws:elasticloadbalancing:us-east-1:99999999999:loadbalancer/net/refactor-spaces-nlb-XXXX/YYYY",<br>    vpc_link_id = "00abcde"<br>    application = {<br>      "application_identifier" = "app-BSXbxAPn1r",<br>      "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ZoiD5hlRyz/application/app-BSXbxAPn1r",<br>      "environment_identifier" = "env-ZoiD5hlRyz",<br>      ...<br>            <all attributes of AWS Migration Hub Refactor Spaces Application: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_application><br>    }<br>    application_proxy_vpc_attributes = {<br>      <all attributes of the awscc_ec2_vpc data source: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/ec2_vpc><br>    }<br>  }<br>]</pre> |
| <a name="output_environment"></a> [environment](#output\_environment) | AWS Migration Hub Refactor Spaces environment resource attributes. Full output of [`awscc_refactorspaces_environment`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_environment) |
| <a name="output_services"></a> [services](#output\_services) | Collection of AWS Migration Hub Refactor Spaces Services and associated routes.<br><br>Example:<pre>services = [<br>  {<br>    "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/service/svc-XYZ"<br>    "name" = "legacy",<br>    description = "The legacy monolithic application entry point"<br>    routes = [<br>      {<br>        "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/route/rte-ABCD"<br>        "route_identifier" = "rte-ABCD"<br>        "route_type": "DEFAULT"<br>        ...<br>        <all attributes of AWS Migration Hub Refactor Spaces Route: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_route><br>      }<br>    ]<br>    ...<br>    <all attributes of AWS Migration Hub Refactor Spaces Service: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_service><br>  }<br>]</pre> |
<!-- END_TF_DOCS -->