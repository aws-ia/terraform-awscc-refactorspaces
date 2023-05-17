variable "environment_name" {
  type        = string
  description = "Name of the AWS Migration Hub Refactor Spaces environment."
}

variable "environment_description" {
  type        = string
  description = "(Optional) Description for the AWS Migration Hub Refactor Spaces environment."
  default     = null
}

variable "provision_network_bridge" {
  type        = bool
  description = "When `true` AWS Migration Hub Refactor Spaces creates and manages an AWS Transit Gateway to establish cross-account network connectivity for this environment. Default: false."
  default     = false
}

variable "shared_to_principals" {
  description = <<-EOF
  Optional list of AWS principals to share the AWS Migration Hub Refactor Spaces environment.

  Please Note: The setting `Enable sharing with AWS Organizations` under the Resource Access Manager service must be enabled on the master account for your organization to share the organizational unit or to share with the entire organization. For more information, see https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html.
  
  Allowed values are: 
  - 12-digit AWS account IDs;
  - ARN of the organization or;
  - ARN of the organizational units
EOF
  type        = list(string)
  default     = []
}

variable "resource_tags" {
  description = "Tags to set for all resources."
  type        = map(string)
  default     = {}
}