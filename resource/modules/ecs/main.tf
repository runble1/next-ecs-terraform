variable "cluster_name" {}
variable "vpc_id" {}
locals {
  app_name = "next"
}

####################################################
# ECS Cluster
####################################################
resource "aws_ecs_cluster" "cluster" {
  name               = var.cluster_name
  capacity_providers = ["FARGATE"]
  default_capacity_provider_strategy {
    capacity_provider = "FARGATE"
  }
  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

####################################################
# ECS Task
####################################################
resource "aws_ecs_task_definition" "task" {
  family                   = "httpd-task"
  #0.25vCPU
  cpu                      = "256"
  #0.5GB
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  container_definitions = <<JSON
  [
    {
      "name": "print-env-app",
      "image": "657885203613.dkr.ecr.ap-northeast-1.amazonaws.com/next-docker",
      "essential": true,
      "portMappings": [
        {
          "protocol": "tcp",
          "containerPort": 8000
        }
      ],
      "environment": [
        { "name": "MY_VARIABLE", "value": "Hello World!!" }
      ]
    }
  ]
    JSON
}

####################################################
# ECS Service
####################################################
resource "aws_ecs_service" "service" {
  name                              = "httpd-service"
  cluster                           = aws_ecs_cluster.cluster.arn
  task_definition                   = aws_ecs_task_definition.task.arn
  desired_count                     = 1
  launch_type                       = "FARGATE"
  platform_version                  = "1.4.0"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.service.id]
    subnets = module.vpc.public_subnets
  }

  ## デプロイ毎にタスク定義が更新されるため、リソース初回作成時を除き変更を無視
  lifecycle {
    ignore_changes = [task_definition]
  }
}

####################################################
# Security Group
####################################################
resource "aws_security_group" "service" {
  name        = "httpd-sg"
  description = "httpd-sg"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "httpd-sg"
  }
}