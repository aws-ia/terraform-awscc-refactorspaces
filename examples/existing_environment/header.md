
# Example : Deploy a Microservice to an existing shared Application

The following example creates a new AWS Migration Hub Refactor Spaces service based on an AWS Lambda function and a route for `GET` and `POST` methods to the path `/unicorns/reviews` in an existing AWS Migration Hub Refactor Spaces Application deployed in, or shared with the executing AWS Account. Use case for this would be to deploy Environment and application in separate CI/CD pipelines and deploy the Service as part of the microservice CI/CD pipeline in a separate account.

This example would deploy the following:

* A AWS Migration Hub Refactor Spaces service "Unistore-AddReview" pointing at a microservice deployed as AWS Lambda Function with the ARN `arn:aws:lambda:us-east-1:999999999999:function:AddReview` in an existing AWS Migration Hub Refactor Spaces application shared with the Account with the id `app-xy1ABCDE1a` in the environment `env-ab9ZXYVT9z`. 
* A route that sends `POST` and `GET` requests to `/unicorns/reviews` to the AWS Lambda function