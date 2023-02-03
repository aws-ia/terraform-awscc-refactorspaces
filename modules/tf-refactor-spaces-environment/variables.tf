variable "environment_name" {
  type        = string
  description = "The name of the AWS Migration Hub Refactor Spaces environment"
}

variable "environment_description" {
  type        = string
  description = "A description for the AWS Migration Hub Refactor Spaces environment (optional)"
  default     = null
}

variable "shared_to_principals" {
  description = <<-EOF
  An optional list of AWS principals to share the AWS Migration Hub Refactor Spaces environment.

  Please Note: The setting `Enable sharing with AWS Organizations` under the Resource Access Manager service must be enabled on the master account for your organization in order to share Organizational unit or to the entire Organization. See: https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html for further details.
  
  Allowed values are: 
  - 12-digit AWS account ID's;
  - ARN of the Organization or;
  - ARN of the Organizational Units
EOF
  type        = list(string)
  default     = []
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}