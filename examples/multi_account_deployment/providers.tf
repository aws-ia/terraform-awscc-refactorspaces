terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0.0, < 5.0.0"
    }
    awscc = {
      source  = "hashicorp/awscc"
      version = ">= 0.49.0"
    }
  }
}

provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_provider_profile_central_management
  alias                    = "central-mgmt"
  shared_config_files      = [var.aws_shared_config_file_path]
  shared_credentials_files = [var.aws_shared_credentials_file_path]

  ignore_tags {
    key_prefixes = ["refactor-spaces:"]
  }
}

provider "awscc" {
  region                   = var.aws_region
  profile                  = var.aws_provider_profile_central_management
  alias                    = "central-mgmt"
  shared_config_files      = [var.aws_shared_config_file_path]
  shared_credentials_files = [var.aws_shared_credentials_file_path]
}

provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_provider_profile_mod_frontend
  alias                    = "unistore-frontend"
  shared_config_files      = [var.aws_shared_config_file_path]
  shared_credentials_files = [var.aws_shared_credentials_file_path]

  ignore_tags {
    key_prefixes = ["refactor-spaces:"]
  }
}

provider "awscc" {
  region                   = var.aws_region
  profile                  = var.aws_provider_profile_mod_frontend
  alias                    = "unistore-frontend"
  shared_config_files      = [var.aws_shared_config_file_path]
  shared_credentials_files = [var.aws_shared_credentials_file_path]
}

provider "aws" {
  region                   = var.aws_region
  profile                  = var.aws_provider_profile_microservice_usermgmt
  alias                    = "unistore-userservice"
  shared_config_files      = [var.aws_shared_config_file_path]
  shared_credentials_files = [var.aws_shared_credentials_file_path]

  ignore_tags {
    key_prefixes = ["refactor-spaces:"]
  }
}

provider "awscc" {
  region                   = var.aws_region
  profile                  = var.aws_provider_profile_microservice_usermgmt
  alias                    = "unistore-userservice"
  shared_config_files      = [var.aws_shared_config_file_path]
  shared_credentials_files = [var.aws_shared_credentials_file_path]
}