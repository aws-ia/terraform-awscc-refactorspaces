variable "environment_name" {
  type        = string
  description = "The name of the AWS Migration Hub Refactor Spaces environment. Required if creating the environment."
  default     = null
}

variable "environment_description" {
  type        = string
  description = "A description for the AWS Migration Hub Refactor Spaces environment (optional)"
  default     = null
}

variable "provision_network_bridge" {
  type        = bool
  description = "When `true` AWS Migration Hub Refactor Spaces creates and manages an AWS Transit Gateway to establish cross account network connectivity for this environment. Default: false"
  default     = false
}

variable "shared_to_principals" {
  description = <<-EOF
  An optional list of AWS principals to share the AWS Migration Hub Refactor Spaces environment.

  Please Note: The setting `Enable sharing with AWS Organizations` under the Resource Access Manager service must be enabled on the master account for your organization in order to share Organizational unit or to the entire Organization. See: https://docs.aws.amazon.com/ram/latest/userguide/getting-started-sharing.html for further details.
  
  Allowed values are: 
  - 12-digit AWS account ID's;
  - ARN of the Organization or;
  - ARN of the Organizational Units

  Example:
  ```
  shared_to_principals = [
    "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-abcde01r",
    "arn:aws:organizations::123456789012:ou/o-l6bam5e5ba/ou-23gz-rstuv02r",
  ]
  ```
EOF
  type        = list(string)
  default     = []
}

variable "environment_id" {
  description = "AWS Migration Hub Refactor Spaces Environment Id to use if not creating the Environment."
  default     = null
  type        = string
}

variable "application_id" {
  description = "AWS Migration Hub Refactor Spaces Application id to use if not creating the application."
  default     = null
  type        = string
}

variable "applications" {
  description = <<-EOF
  List of AWS Migration Hub Refactor Spaces applications to create. 

  Properties:
  - `application_name`                       = (Required|string) The name of the application
  - `proxy_type`                             = (Optional|string) The proxy type for the application. `REGIONAL` APIs are publicly accessible in the current Region. `PRIVATE` APIs are accessible only from VPCs. Default: REGIONAL.
  - `apigateway_stage_name`                  = (Optional|string) The name of the API Gateway stage to use for the application proxy. The name defaults to prod.
  - `application_proxy_vpc_id`               = (Required|string) The Amazon Virtual Private Cloud (VPC) id of VPC to deploy the application's proxy.

  Example:
  ```
  applications = [
    {
      application_name         = "Unistore"
      proxy_type               = "PRIVATE"
      application_proxy_vpc_id = "vpc-XYZ"
      apigateway_stage_name    = "dev"
    },
    {
      application_name         = "Unistore-Prod"
      proxy_type               = "REGIONAL"
      application_proxy_vpc_id = "vpc-ABC"
      apigateway_stage_name    = "prod"
    }
  ]
  ```
EOF
  type = list(object({
    application_name         = string
    proxy_type               = string
    apigateway_stage_name    = optional(string)
    application_proxy_vpc_id = string
  }))
  default = []
  validation {
    condition = var.applications == null || alltrue([for application in var.applications : alltrue(
      [
        can(regex("^vpc-", application.application_proxy_vpc_id)),
        contains(["REGIONAL", "PRIVATE"], application.proxy_type)
      ]
      )
    ])
    error_message = "The provided application definition is invalid. Check that the application_proxy_vpc_id for all applications conform to the input types in the description"
  }
}

variable "services" {
  description = <<-EOF
  List of AWS Migration Hub Refactor Spaces service specifications and their routing configuration. 

  Properties:
  - `name`             = (Required|string) The name of the service
  - `application_name` = (Required|string) The name of the application to associate the service
  - `description`      = (Optional|string) A description of the service
  - `endpoint_type`    = (Required|string) The endpoint type of the service; allowed type is `"URL"` or `"LAMBDA"`
  - `lambda_arn`       = (Optional|string) The Amazon Resource Name (ARN) of the Lambda function to use for the endpoint. Required if `endpoint_type = "LAMBDA"`
  - `url_endpoint`     = (Optional|string) The URL to route traffic to. The URL must be an rfc3986-formatted URL. If the host is a domain name, the name must be resolvable over the public internet. Required if `endpoint_type = "URL"`
  - `health_url`       = (Optional|string) The health check URL of the URL endpoint type. If the URL is a public endpoint, the HealthUrl must also be a public endpoint.
  - `vpc_id`           = (Optional|string) The ID of the virtual private cloud (VPC) hosting the URL to route traffic to.
  - `routes`           = (Optional|list(object)) A collection of routes to associate with the service.
    - `source_path`         = (Required|string) (Required|string) The path to use to match traffic. Paths must start with / and are relative to the base of the application. If the route is the default this should be set as '/'
    - `include_child_paths` = (Optional|bool) Indicates whether to match all subpaths of the given source path. If this value is `false`, requests must match the source path exactly before they are forwarded to this route's service. Default true.
    - `http_verbs`          = (Optional|list(string)) A list of HTTP methods to match. An empty list matches all values. Default all values.
    - `route_active`        = (Required|bool) If set to `true`, traffic is forwarded to this route’s service after the route is created.

  Example:
  ```
  services = [
    {
      name                                   = "Unistore-legacy"
      application_name                       = "Unistore"
      description                            = "The legacy monolithic application entry point"
      endpoint_type                          = "URL"
      url_endpoint                           = "http://legacy.example.com"
      vpc_id                                 = "vpc-XYZ"
      routes = [
        {
          source_path         = "/"     # Default route
          route_active        = true
        }
      ]
    },
    {
      name              = "Unistore-MicroServer"
      application_name  = "Unistore"
      description       = "The new Microservice"
      endpoint_type     = "LAMBDA"
      lambda_arn        = "arn:aws:lambda:us-east-1:123456789012:function:Test"
      routes = [
        {
          source_path         = "/unicorns/basket"
          include_child_paths = true
          http_verbs          = ["POST","GET"]
          route_active        = true
        }
      ]
    }
  ]
  ```
EOF
  type = list(object({
    name             = string
    application_name = string
    description      = optional(string)
    endpoint_type    = string
    lambda_arn       = optional(string)
    url_endpoint     = optional(string)
    health_url       = optional(string)
    vpc_id           = optional(string)
    routes = optional(list(object({
      source_path         = string
      include_child_paths = optional(bool)
      http_verbs          = optional(list(string))
      route_active        = bool
    })))
  }))
  validation {
    condition = var.services == null || alltrue(
      [for service_definition in var.services : alltrue(
        [
          contains(["URL", "LAMBDA"], service_definition.endpoint_type),
          (
            ((service_definition.endpoint_type == "LAMBDA") && (service_definition.lambda_arn != null)) ||
            ((service_definition.endpoint_type == "URL") && (service_definition.url_endpoint != null) && (service_definition.vpc_id != null))
          )
        ])
      ]
    )
    error_message = "The provided service definition for the endpoint type was invalid. Check that the correct 'endpoint_type' was set and the mandatory values ('lambda_arn' for Lambda or 'url_endpoint' and 'vpc_id' for URL) were provided."
  }
  default = []
}

variable "resource_tags" {
  description = "Tags to set for all resources"
  type        = map(string)
  default     = {}
}