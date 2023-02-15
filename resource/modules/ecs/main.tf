variable "cluster_name" {}
variable "vpc_id" {}
variable "subnet_1a_id" {}
variable "subnet_1c_id" {}
variable "alb_target_group_arn" {}
locals {
  app_name = "next"
}

####################################################
# ECS Cluster
####################################################
resource "aws_ecs_cluster" "cluster" {
  name = var.cluster_name

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
  family                   = "print-env-app-task-definition"
  cpu                      = "256"
  memory                   = "512"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn

  container_definitions = jsonencode([
    {
      name         = local.app_name,
      image        = "657885203613.dkr.ecr.ap-northeast-1.amazonaws.com/next-docker:ba9715eafc2d300aac3f06f6955b88ce66178e00",
      "essential"  = true,
      portMappings = [
        {
          containerPort = 3000 #Fargateは containerPortのみ
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-region : "ap-northeast-1"
          awslogs-group : aws_cloudwatch_log_group.frontend.name
          awslogs-stream-prefix : "ecs"
        }
      },
      healthcheck = {
        command = [
          "CMD-SHELL",
          "wget -q -O - http://localhost:3000/api/healthcheck|| exit 1"
        ],
        interval = 5,
        retries = 3,
        startPeriod = 60,
        timeout = 5
      },
    }
  ])

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64" // M1でビルドした用
  }
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "ecs_task_execution_role" {
  name               = "MyEcsTaskRole"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

resource "aws_iam_role_policy_attachment" "amazon_ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

####################################################
# ECS Service
####################################################
resource "aws_ecs_service" "service" {
  name             = "httpd-service"
  cluster          = aws_ecs_cluster.cluster.arn
  task_definition  = aws_ecs_task_definition.task.arn
  desired_count    = 1
  launch_type      = "FARGATE"
  platform_version = "1.4.0"

  network_configuration {
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = [var.subnet_1a_id, var.subnet_1c_id]
  }

  load_balancer {
    target_group_arn = var.alb_target_group_arn
    container_name   = local.app_name
    container_port   = 3000
  }

  ## デプロイ毎にタスク定義が更新されるため、リソース初回作成時を除き変更を無視
  lifecycle {
    ignore_changes = [task_definition]
  }
}

####################################################
# Security Group
####################################################
resource "aws_security_group" "ecs_tasks" {
  name        = "nextjs-sg-ecs-tasks"
  description = "nextjs-sg-ecs-tasks"
  vpc_id      = var.vpc_id
  ingress {
    from_port   = 3000
    to_port     = 3000
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

####################################################
# ECS Task Container Log Groups
####################################################
resource "aws_cloudwatch_log_group" "frontend" {
  name              = "/ecs/${local.app_name}/frontend"
  retention_in_days = 30
}