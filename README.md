## AWS ECS infra with Terraform

Configurations for creating hosting environment for website and backend. S3 bucket is created for hosting a static website. ECS service and Fargate task is created for running backend service.

### Dependencies

AWS client
AWS account and IAM user with privileges for used services
Local AWS credentials
Docker account and docker image for backend

### Usage

1. Make sure you have your AWS credentials set in `$HOME/.aws/credentials` (Linux) or in `$USERPROFILE/.aws/credentials` (Windows) for correct AWS environment.

2. Push your Docker image to ECR by following these steps

Set up Docker with ECR by running `aws ecr get-login-password --region <your_region> | docker login --username AWS --password-stdin <your_account_id>.dkr.ecr.<your.region>.amazonaws.com`
Build your Docker image with tag `<your_account_id>.dkr.ecr.<your.region>.amazonaws.com/image:tag`
Push your image to ECR with command `docker push <your_account_id>.dkr.ecr.<your.region>.amazonaws.com/image:tag`

3. Change Fargate task definition according to your image URI.

4. Deploy your website to S3 by running `aws s3 sync /<your_application_build> s3://<your_bucket_name>`

5. Check S3 bucket public address and enjoy!

