variable "aws_shared_config_file_path" {
  type        = string
  description = "Full path to the AWS Config file (~/.aws/config) to use for AWS profile configuration. Required if using multi-account deployment."
  default     = null
}

variable "aws_shared_credentials_file_path" {
  type        = string
  description = "Full path to the AWS Credential file (~/.aws/credential) to use for AWS profile configuration. Required if using multi-account deployment."
  default     = null
}

variable "aws_region" {
  type        = string
  description = "The AWS region to deploy all resources."
  default     = "us-east-1"
  validation {
    condition     = can(regex("^ap-northeast-[1]|ap-southeast-[12]|eu-central-1|eu-north-1|eu-west-[12]|us-east-[12]|us-west-[2]$", var.aws_region))
    error_message = "Unsupported Region for AWS Migration Hub Refactor Spaces (https://docs.aws.amazon.com/general/latest/gr/migrationhub-refactor-spaces.html)."
  }
}

variable "aws_provider_profile_central_management" {
  type        = string
  description = "The AWS profile name defined in the shared configuration file (~/.aws/config) to use for the Refactor Spaces Environment."
  default     = null
}

variable "aws_provider_profile_mod_frontend" {
  type        = string
  description = "The AWS profile name defined in the shared configuration file (~/.aws/config) to use for the modernized front-end (S3, CloudFront, Refactor Spaces Application)."
  default     = null
}

variable "aws_provider_profile_microservice_usermgmt" {
  type        = string
  description = "The AWS profile name defined in the shared configuration file (~/.aws/config) to use for the User Management microservices"
  default     = null
}

variable "unistore_modernized_proxy_vpc_cidr" {
  type        = string
  description = "A CIDR for a VPC provisioned to host the strangler-fig proxy for the modern application"
  default     = "192.168.200.0/24"
}

variable "unistore_modernized_principals" {
  description = <<-EOF
  A list of AWS principals to share the Refactor Spaces environment.

  Please Note: The setting `Enable sharing with AWS Organizations` under the Resource Access Manager service must be enabled on the master account for your organization in order to share Organizational unit or to the entire Organization. See: https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html for further details.
  
  Allowed values are: 
  - 12-digit AWS account ID's;
  - ARN of the Organization or;
  - ARN of the Organizational Units

  Example:
  ```
  unistore_modernized_principals = [
    "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-abcde01r",
    "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-rstuv02r",
  ]
  ```
EOF
  type        = list(string)
  default     = []
}