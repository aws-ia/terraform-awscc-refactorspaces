variable "environment_id" {
  description = "AWS Migration Hub Refactor Spaces environment ID for the application hosting the service."
  type        = string
}

variable "application_id" {
  description = "AWS Migration Hub Refactor Spaces application ID for the application hosting the service."
  type        = string
}

variable "name" {
  type        = string
  description = "Name of the service."
}

variable "description" {
  type        = string
  description = "Description of the service."
  default     = null
}

variable "endpoint_type" {
  type        = string
  description = "Description of the service."
  validation {
    condition     = contains(["URL", "LAMBDA"], var.endpoint_type)
    error_message = "Please provide a valid 'endpoint_type'. Allowed values are 'URL' or 'LAMBDA'."
  }
}

variable "lambda_arn" {
  type        = string
  description = "ARN of the Lambda function to use for the endpoint. Required if `endpoint_type = 'LAMBDA'`."
  default     = null
}

variable "url_endpoint" {
  type        = string
  description = "URL to route traffic to. The URL must be an rfc3986-formatted URL. If the host is a domain name, the name must be resolvable over the public internet. Required if `endpoint_type = `URL`"
  default     = null
}

variable "health_url" {
  type        = string
  description = "Health check URL of the URL endpoint type. If the URL is a public endpoint, the HealthURL must also be a public endpoint."
  default     = null
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC hosting the URL to route traffic to."
  default     = null
  validation {
    condition     = var.vpc_id == null || can(regex("^vpc-", var.vpc_id))
    error_message = "The vpc_id must be a valid VPC ID of the form 'vpc-'."
  }
}

variable "routes" {
  description = <<-EOF
  (Optional) Collection of AWS Migration Hub Refactor Spaces service routes to associate with the service. Required if `default_route = false`.

  Properties:
    - `source_path`         = (Required|string) The path to use to match traffic. Paths must start with / and are relative to the base of the application. If the route is the default this should be set as '/'.
    - `include_child_paths` = (Optional|bool) Indicates whether to match all subpaths of the given source path. If this value is `false`, requests must match the source path exactly before they are forwarded to this route's service. Default true.
    - `http_verbs`          = (Optional|list(string)) A list of HTTP methods to match. An empty list matches all values. Default all values.
    - `route_active`        = (Required|bool) If set to `true`, traffic is forwarded to this route’s service after the route is created.

  Default Route Example:
  ```
  routes = [
    {
      source_path = "/"
      route_active = true
    }
  ]
  ```
  Non-default route examples:
  ```
  routes = [
    {
        source_path         = "/unicorns/basket"
        include_child_paths = true
        http_verbs          = ["POST","GET"]
        route_active        = true
    }
  ]
  ```
EOF
  type = list(object({
    source_path         = string
    include_child_paths = optional(bool)
    http_verbs          = optional(list(string))
    route_active        = bool
  }))
  default = []
}