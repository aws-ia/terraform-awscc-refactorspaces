variable "proxy_vpc_name" {
  type        = string
  description = "Name for the Amazon VPC to host the link for AWS Refactor Spaces to access the monolithic application."
  default     = "vpc-application-example-proxy"
}

variable "proxy_vpc_cidr_block" {
  type        = string
  description = "A 24-bit IPv4 CIDR for the Amazon VPC to host the link for AWS Refactor Spaces to access the monolithic application."
  default     = "192.168.10.0/24"
}

variable "environment_name" {
  type        = string
  description = "Name of the AWS Migration Hub Refactor Spaces environment."
  default     = "Unistore-Dev"
}

variable "environment_description" {
  type        = string
  description = "Description for the AWS Migration Hub Refactor Spaces environment."
  default     = "AWS Migration Hub Refactor Spaces environment for Unicorn Enterprises."
}

variable "application_name" {
  type        = string
  description = "Display name in the AWS Migration Hub Refactor Spaces for the strangled application."
  default     = "Unistore"
}

variable "application_stage_name" {
  type        = string
  description = "Stage name configured on Amazon API Gateway by AWS Migration Hub Refactor Spaces."
  default     = "api"
}

variable "application_proxy_type" {
  type        = string
  description = "Accessibility of the Amazon API Gateway deployed by AWS Migration Hub Refactor Spaces. `REGIONAL` APIs are publicly accessible in the current AWS Region. `PRIVATE` APIs are accessible only from VPCs. Default: REGIONAL."
  default     = "REGIONAL"
}

variable "display_name_monolith_server" {
  type        = string
  description = "Display name for the AWS Migration Hub Refactor Spaces service for the monolithic application."
  default     = "legacy"
}

variable "description_monolith_server" {
  type        = string
  description = "Description for the AWS Migration Hub Refactor Spaces service for the monolithic application."
  default     = "The legacy monolithic application entry point"
}

variable "url_endpoint_monolith" {
  type        = string
  description = "Fully-qualified HTTP/HTTPS URI for the entry point of the current monolithic application running."
  default     = "http://legacy-unicorns.example.com/"
}

variable "vpc_id_monolith" {
  type        = string
  description = "Amazon VPC ID of the current monolithic application running (defined in `var.url_endpoint_monolith`)."
  default     = "http://legacy-unicorns.example.com/"
}


variable "display_name_lambda_microservice" {
  type        = string
  description = "Display name for a Lambda-based microservice configured as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith."
  default     = "Unistore-AddToCartService"
}

variable "description_lambda_microservice" {
  type        = string
  description = "Description for the Lambda-based microservice configured as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith."
  default     = "The new AddToCart Microservice"
}

variable "lambda_arn_microservice" {
  type        = string
  description = "ARN of the Lambda function to use as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith."
  default     = "arn:aws:lambda:us-east-1:999999999999:function:AddToCart"
}

variable "source_path_lambda_microservice" {
  type        = string
  description = "Path AWS Migration Hub Refactor Spaces uses to match traffic destined for the new microservice. Paths must start with / and are relative to the base of the application."
  default     = "/unicorns/basket"
}

variable "http_verbs_lambda_microservice" {
  type        = string
  description = "List of HTTP methods AWS Migration Hub Refactor Spaces uses to match traffic destined for the new microservice."
  default     = ["POST", "GET"]
}