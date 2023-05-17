variable "environment_id" {
  description = "AWS Migration Hub Refactor Spaces environment ID that the AWS Migration Hub Refactor Spaces application creates."
  type        = string
}

variable "application_name" {
  type        = string
  description = "AWS Migration Hub Refactor Spaces applications name."
}

variable "proxy_type" {
  type        = string
  description = "AWS Migration Hub Refactor Spaces proxy type. Regional APIs are publicly accessible in the current Region. Private APIs are accessible only from VPCs. Default: REGIONAL"
  default     = "REGIONAL"
  validation {
    condition     = contains(["REGIONAL", "PRIVATE"], var.proxy_type)
    error_message = "The variable proxy_type value must be set to either 'REGIONAL', or 'PRIVATE'."
  }
}

variable "apigateway_stage_name" {
  type        = string
  description = "Name of the Amazon API Gateway stage that deploys to host the AWS Migration Hub Refactor Spaces application. The name defaults to prod."
  default     = "prod"
}

variable "application_proxy_vpc_id" {
  type        = string
  description = "Amazon VPC ID for the VPC hosting the components for the AWS Migration Hub Refactor Spaces."
  validation {
    condition     = can(regex("^vpc-", var.application_proxy_vpc_id))
    error_message = "The application_proxy_vpc_id must be a valid Virtual Private Cloud (VPC) id of the form 'vpc-'."
  }
}

/*
# Tagging of AWS::RefactorSpaces::Application in non-environment owner account (multi-account deployment) not currently supported
# due to dependent service (Amazon API Gateway) not supporting operation currently.
variable "resource_tags" {
  description = "Tags to set for all resources."
  type        = map(string)
  default     = {}
}
*/