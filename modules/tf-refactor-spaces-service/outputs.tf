output "service" {
  value       = awscc_refactorspaces_service.current
  description = "AWS Migration Hub Refactor Spaces service resource attributes. Full output of [`awscc_refactorspaces_service`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_service)."
}

output "routes" {
  description = "Collection of the AWS Migration Hub Refactor Spaces route resource attributes. Full output of [`awscc_refactorspaces_service`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_route)."
  value       = merge(awscc_refactorspaces_route.default, awscc_refactorspaces_route.non_default)
}