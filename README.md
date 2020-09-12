## AWS ECS infra with Terraform

Configurations for creating hosting environment for website and backend. S3 bucket is created for hosting a static website. ECS service and Fargate task is created for running backend service.

### Dependencies

AWS client

AWS account and IAM user with privileges for used services

Docker

Terraform

### Usage

Clone this repo to your local environment and run `terraform init` in project root.

Make sure you have your AWS credentials set in `$HOME/.aws/credentials` (Linux) or in `$USERPROFILE\.aws\credentials` (Windows) for correct AWS environment. AWS profile is given in `variables.tf`.

Check that configuration is working by running `terraform plan`. If no problems exist deploy configuration to aws by running `terraform apply`.

Push your Docker image to ECR by following these steps

- Set up Docker with ECR by running `aws ecr get-login-password --region <your_region> | docker login --username AWS --password-stdin <your_account_id>.dkr.ecr.<your.region>.amazonaws.com`

- Build your Docker image with tag `<your_account_id>.dkr.ecr.<your.region>.amazonaws.com/image:tag`

- Push your image to ECR with command `docker push <your_account_id>.dkr.ecr.<your.region>.amazonaws.com/image:tag`

Change Fargate task definition according to your image URI.

Deploy your website to S3 by running `aws s3 sync /<your_application_build> s3://<your_bucket_name>`

Check S3 bucket public address and enjoy!

