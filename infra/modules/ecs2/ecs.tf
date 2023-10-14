####################################################
# ECS Cluster
####################################################
resource "aws_ecs_cluster" "cluster" {
  name = "${var.service}-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.cluster.name

  capacity_providers = ["FARGATE"]

  default_capacity_provider_strategy {
    base              = 1
    weight            = 100
    capacity_provider = "FARGATE"
  }
}

####################################################
# SG ALB -> ECS
####################################################
resource "aws_security_group" "ecs" {
  name        = "${var.env}-${var.service}-ecs-sg"
  description = "${var.env}-${var.service}-ecs-sg"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.env}-${var.service}-ecs-sg"
  }
}

resource "aws_security_group_rule" "ecs_from_alb" {
  type      = "ingress"
  from_port = var.app_port
  to_port   = var.app_port
  protocol  = "tcp"

  cidr_blocks = ["0.0.0.0/0"]
  #source_security_group_id = var.alb_sg_id

  security_group_id = aws_security_group.ecs.id
}
