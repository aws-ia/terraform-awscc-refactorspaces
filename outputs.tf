output "environment" {
  value       = local.environment
  description = "AWS Migration Hub Refactor Spaces environment resource attributes. Full output of [`awscc_refactorspaces_environment`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_environment)."
}

output "applications" {
  value       = local.application_objects
  description = <<-EOF
  Collection of AWS Migration Hub Refactor Spaces application managed by or used.

  Example:
  ```
  applications = [
    {
      api_gateway_id = "a0abcdefg1o1"
      nlb_arn = "arn:aws:elasticloadbalancing:us-east-1:99999999999:loadbalancer/net/refactor-spaces-nlb-XXXX/YYYY",
      vpc_link_id = "00abcde"
      application = {
        "application_identifier" = "app-BSXbxAPn1r",
        "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ZoiD5hlRyz/application/app-BSXbxAPn1r",
        "environment_identifier" = "env-ZoiD5hlRyz",
        ...
              <all attributes of AWS Migration Hub Refactor Spaces Application: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_application>
      }
      application_proxy_vpc_attributes = {
        <all attributes of the awscc_ec2_vpc data source: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/ec2_vpc>
      }
    }
  ]
EOF
}

output "services" {
  value       = local.service_objects
  description = <<-EOF
  Collection of AWS Migration Hub Refactor Spaces services and associated routes.

  Example:
  ```
  services = [
    {
      "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/service/svc-XYZ"
      "name" = "legacy",
      description = "The legacy monolithic application entry point"
      routes = [
        {
          "arn" = "arn:aws:refactor-spaces:us-east-1:99999999999:environment/env-ABC/application/app-XYZ/route/rte-ABCD"
          "route_identifier" = "rte-ABCD"
          "route_type": "DEFAULT"
          ...
          <all attributes of AWS Migration Hub Refactor Spaces Route: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_route>
        }
      ]
      ...
      <all attributes of AWS Migration Hub Refactor Spaces Service: https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_service>
    }
  ]
  ```
EOF
}