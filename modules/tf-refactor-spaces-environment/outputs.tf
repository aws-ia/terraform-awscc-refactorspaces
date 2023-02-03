output "environment" {
  value       = awscc_refactorspaces_environment.this
  description = "AWS Migration Hub Refactor Spaces environment resource attributes. Full output of [`awscc_refactorspaces_environment`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_environment)"
}

output "resource_share_id" {
  value       = aws_ram_resource_association.refactor_spaces_environment.id
  description = "The Amazon Resource Name (ARN) of the AWS Resource Access Manager share created for the AWS Migration Hub Refactor Spaces environment."
}

output "resource_share_prinicpals" {
  value       = var.shared_to_principals
  description = "A list of AWS principals associated by terraform for the AWS Resource Access Manager share."
}