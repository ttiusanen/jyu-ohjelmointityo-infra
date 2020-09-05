variable "aws_region" {
  default = "eu-north-1"
}

variable "aws_profile" {
  default = "default"
}

variable "vpc_cidr" {
  default = "10.241.16.0/21"
}

variable "public_subnet_cidrs" {
  default = ["10.241.16.0/22", "10.241.20.0/22"]
}

variable "az_count" {
  description = "How many AZs to span our infra to"
  default     = 2
}

variable "ecs_cluster_name" {
  default = "demo-ecs-cluster"
}

variable "ecs_service_name" {
  default = "demo-ecs-service"
}


