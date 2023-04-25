variable "proxy_vpc_name" {
  type        = string
  description = "A name for a the Amazon Virtual Private Cloud (VPC) created to host the VPC Link for Refactor Spaces to access the monolithic application."
  default     = "vpc-application-example-proxy"
}

variable "proxy_vpc_cidr_block" {
  type        = string
  description = "A 24-bit IPv4 CIDR to for the Amazon Virtual Private Cloud (VPC) created to host the VPC Link for Refactor Spaces to access the monolithic application."
  default     = "192.168.10.0/24"
}

variable "environment_name" {
  type        = string
  description = "The name of the AWS Migration Hub Refactor Spaces environment that will be created."
  default     = "Unistore-Dev"
}

variable "environment_description" {
  type        = string
  description = "A description for the AWS Migration Hub Refactor Spaces environment."
  default     = "AWS Migration Hub Refactor Spaces environment for Unicorn Enterprises."
}

variable "application_name" {
  type        = string
  description = "The display name in AWS Migration Hub Refactor Spaces for the application being strangled."
  default     = "Unistore"
}

variable "application_stage_name" {
  type        = string
  description = "The stage name which will be configured on Amazon API Gateway by AWS Migration Hub Refactor Spaces for the application."
  default     = "api"
}

variable "application_proxy_type" {
  type        = string
  description = "The accessibility of the Amazon API Gateway that is deployed by AWS Migration Hub Refactor Spaces for the application. `REGIONAL` APIs are publicly accessible in the current Region. `PRIVATE` APIs are accessible only from VPCs. Default: REGIONAL."
  default     = "REGIONAL"
}

variable "display_name_monolith_server" {
  type        = string
  description = "A display name for the AWS Migration Hub Refactor Spaces service for the monolithic application."
  default     = "legacy"
}

variable "description_monolith_server" {
  type        = string
  description = "A description for the the AWS Migration Hub Refactor Spaces service for the monolithic application."
  default     = "The legacy monolithic application entry point"
}

variable "url_endpoint_monolith" {
  type        = string
  description = "A fully-qualified HTTP/HTTPS URI for the entry point of the current monolithic application running."
  default     = "http://legacy-unicorns.example.com/"
}

variable "vpc_id_monolith" {
  type        = string
  description = "A Amazon Virtual Private Cloud (VPC) id of the VPC where the current monolithic application (defined in `var.url_endpoint_monolith` running."
  default     = "http://legacy-unicorns.example.com/"
}


variable "display_name_lambda_microservice" {
  type        = string
  description = "A display name for a Lambda based microservice configured as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith."
  default     = "Unistore-AddToCartService"
}

variable "description_lambda_microservice" {
  type        = string
  description = "A description for the the Lambda based microservice configured as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith."
  default     = "The new AddToCart Microservice"
}

variable "lambda_arn_microservice" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the Lambda function to use as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith."
  default     = "arn:aws:lambda:us-east-1:999999999999:function:AddToCart"
}

variable "source_path_lambda_microservice" {
  type        = string
  description = "The path AWS Migration Hub Refactor Spaces will use to match traffic destined for the new microservice. Paths must start with / and are relative to the base of the application."
  default     = "/unicorns/basket"
}

variable "http_verbs_lambda_microservice" {
  type        = string
  description = "A list of HTTP methods AWS Migration Hub Refactor Spaces will use to to match traffic destined for the new microservice."
  default     = ["POST", "GET"]
}