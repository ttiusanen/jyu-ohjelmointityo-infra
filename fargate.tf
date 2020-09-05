# Fargate infra 
resource "aws_ecs_cluster" "demo_projects" {
  name = var.ecs_cluster_name
}

resource "aws_ecs_task_definition" "task_definition" {
  family                   = "demo-projects-fargate-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "512"
  memory                   = "4096"
  task_role_arn            = aws_iam_role.fargate_role.arn
  execution_role_arn       = aws_iam_role.fargate_execution_role.arn
  container_definitions = <<DEFINITION
    [
      {
        "image": "nginx:latest", 
        "cpu": 512,
        "memory": 4096,
        "name": "app",
        "networkMode": "awsvpc",
        "logConfiguration": {
            "logDriver": "awslogs",
            "options": {
              "awslogs-group": "/ecs/",
              "awslogs-region": "eu-north-1",
              "awslogs-stream-prefix": "fargate-task"
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
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    security_groups  = [aws_security_group.fargate_demo.id]
    subnets          = aws_subnet.public.*.id
    assign_public_ip = true
  }
}


## Fargate execution role 
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

resource "aws_iam_policy" "fargate_execution_policy" {
  name   = "fargate-execution-policy"
  path   = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ecr:GetAuthorizationToken",
        "ecr:BatchCheckLayerAvailability",
        "ecr:GetDownloadUrlForLayer",
        "ecr:BatchGetImage",
        "logs:CreateLogStream",
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

## Fargate task role 
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