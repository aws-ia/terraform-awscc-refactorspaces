module "refactor_spaces_microservice_x" {
  source  = "aws-ia/refactor-spaces/aws"
  version = "0.1.0"

  environment_id = "env-ab9ZXYVT9z"
  application_id = "app-xy1ABCDE1a"
  services = [
    {
      application_name = "Unistore"
      name             = "Unistore-AddReview"
      description      = "The new AddReview Microservice"
      endpoint_type    = "LAMBDA"
      lambda_arn       = "arn:aws:lambda:us-east-1:999999999999:function:AddReview"
      routes = [
        {
          source_path         = "/unicorns/reviews"
          include_child_paths = true
          http_verbs          = ["POST", "GET"]
          route_active        = true
        }
      ]
    }
  ]
}