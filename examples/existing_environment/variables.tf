variable "environment_id" {
  description = "AWS Migration Hub Refactor Spaces Environment Id of an already deployed environment to use to deploy the new microservice."
  default     = "env-ab9ZXYVT9z"
  type        = string
}

variable "application_id" {
  description = "AWS Migration Hub Refactor Spaces Application id of the deployed application to configure the new microservice."
  default     = "app-xy1ABCDE1a"
  type        = string
}

variable "application_name" {
  type        = string
  description = "The display name of an existing AWS Migration Hub Refactor Spaces application to add the microservice."
  default     = "Unistore"
}

variable "display_name_lambda_microservice" {
  type        = string
  description = "A display name for a new Lambda based microservice to add to an existing AWS Migration Hub Refactor Spaces application to strangle a function of the monolith."
  default     = "Unistore-AddReview"
}

variable "description_lambda_microservice" {
  type        = string
  description = "A description for the the Lambda based microservice to add to an existing AWS Migration Hub Refactor Spaces application."
  default     = "The new AddToCart Microservice"
}

variable "lambda_arn_microservice" {
  type        = string
  description = "The Amazon Resource Name (ARN) of the Lambda function to use as AWS Migration Hub Refactor Spaces service to strangle a function of the monolith."
  default     = "arn:aws:lambda:us-east-1:999999999999:function:AddReview"
}

variable "source_path_lambda_microservice" {
  type        = string
  description = "The path AWS Migration Hub Refactor Spaces will use to match traffic destined for the new microservice. Paths must start with / and are relative to the base of the application."
  default     = "/unicorns/reviews"
}

variable "http_verbs_lambda_microservice" {
  type        = string
  description = "A list of HTTP methods AWS Migration Hub Refactor Spaces will use to to match traffic destined for the new microservice."
  default     = ["POST", "GET"]
}