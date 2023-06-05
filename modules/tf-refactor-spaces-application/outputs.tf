output "application" {
  value       = awscc_refactorspaces_application.current
  description = "AWS Migration Hub Refactor Spaces Application resource attributes. Full output of [`awscc_refactorspaces_application`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/resources/refactorspaces_application) resource."
}

output "application_proxy_vpc_attributes" {
  value       = data.awscc_ec2_vpc.application_proxy_vpc
  description = "Proxy VPC resource attributes. The full output of [`awscc_ec2_vpc`](https://registry.terraform.io/providers/hashicorp/awscc/latest/docs/data-sources/ec2_vpc) data source used to host the Application Proxy VPC for the AWS Migration Hub Refactor Spaces application."
}

output "api_gateway_id" {
  value       = awscc_refactorspaces_application.current.api_gateway_id
  description = "Unique identifier of the Amazon API Gateway created for the AWS Migration Hub Refactor Spaces application."
}

output "nlb_arn" {
  value       = awscc_refactorspaces_application.current.nlb_arn
  description = "ARN of the Network Load Balancer created for the AWS Migration Hub Refactor Spaces application."
}

output "vpc_link_id" {
  value       = awscc_refactorspaces_application.current.vpc_link_id
  description = "Unique identifier of the AWS PrivateLink endpoint created for the AWS Migration Hub Refactor Spaces application."
}
