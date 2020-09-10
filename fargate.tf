# Set up Elastic Container Service
resource "aws_ecs_cluster" "demo_projects" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "issueapp_task_definition" {
  family                   = "demo-projects-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "4096"
  task_role_arn            = aws_iam_role.fargate_role.arn
  execution_role_arn       = aws_iam_role.fargate_execution_role.arn
  container_definitions = <<DEFINITION
    [
      {
        "image": "396253542776.dkr.ecr.eu-north-1.amazonaws.com/issueapp-backend:v1.0", 
        "cpu": 512,
        "memory": 4096,
        "name": "issueapp",
        "networkMode": "awsvpc",
        "portMappings": [
          {
            "containerPort": 8080,
            "hostPort": 8080
          }
        ],
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "/ecs/",
              "awslogs-region": "eu-north-1",
              "awslogs-stream-prefix": "issueapp",
              "awslogs-create-group": "true"
            }
        },
        "environment" : [
            { "name" : "LOGLEVEL", "value" : "INFO" }
        ]
      }
    ]
DEFINITION
}

resource "aws_ecs_service" "demo_service" {
  name            = var.ecs_service_name
  cluster         = aws_ecs_cluster.demo_projects.id
  task_definition = aws_ecs_task_definition.issueapp_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.fargate_demo.id]
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.issueapp.arn
    container_name   = "issueapp"
    container_port   = 8080
  }
}


# Fargate execution role 
resource "aws_iam_role" "fargate_execution_role" {
  name               = "fargate-execution-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

#        "ecr:GetAuthorizationToken",
#        "ecr:BatchCheckLayerAvailability",
#        "ecr:GetDownloadUrlForLayer",
#        "ecr:BatchGetImage",

resource "aws_iam_policy" "fargate_execution_policy" {
  name   = "fargate-execution-policy"
  path   = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:*",
        "logs:CreateLogStream",
        "logs:CreateLogGroup",
        "logs:PutLogEvents"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "fargate_execution_policy_attachment" {
  role       = aws_iam_role.fargate_execution_role.name
  policy_arn = aws_iam_policy.fargate_execution_policy.arn
}

# Fargate task role 
resource "aws_iam_role" "fargate_role" {
  name               = "fargate-task-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

data "aws_iam_policy_document" "fargate_policy_document" {
  statement {
    actions = [
      "s3:*",
      "sqs:*",
      "ecr:*",
    ]
    resources = [
      "*",
    ]
    effect = "Allow"
  }
}

resource "aws_iam_policy" "fargate_policy" {
  name   = "fargate-task-policy"
  path   = "/"
  policy = data.aws_iam_policy_document.fargate_policy_document.json
}

resource "aws_iam_role_policy_attachment" "fargate_policy_attachment" {
  role       = aws_iam_role.fargate_role.name
  policy_arn = aws_iam_policy.fargate_policy.arn
}

resource "aws_cloudwatch_log_group" "ecs_logs" {
  name = "/ecs/"

  tags = {
    Environment = "production"
    Application = "serviceA"
  }
}