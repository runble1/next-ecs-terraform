resource "null_resource" "ecspresso" {
  triggers = {
    cluster            = aws_ecs_cluster.cluster.name,
    execution_role_arn = aws_iam_role.ecs_task_execution_role.arn,
  }

  provisioner "local-exec" {
    command     = "ecspresso deploy"
    working_dir = "."
    environment = { // 環境変数で依存リソースの値(ecspressoで参照するもの)を渡す
      ECS_CLUSTER        = aws_ecs_cluster.cluster.name,
      EXECUTION_ROLE_ARN = aws_iam_role.ecs_task_execution_role.arn,
      TASK_ROLE_ARN      = aws_iam_role.ecs_task_role.arn,
      SECURITY_GROUP_ID  = aws_security_group.ecs.id,
      SUBNET_1A_ID       = var.subnet_private_1a_id,
      SUBNET_1C_ID       = var.subnet_private_1c_id,
      TARGET_GROUP_ARN   = var.alb_target_group_arn,
      IMAGE_URL          = aws_ssm_parameter.image_url.value
    }
  }

  provisioner "local-exec" {
    command     = "ecspresso scale --tasks 0 && ecspresso delete --force"
    working_dir = "."
    when        = destroy // terraform destroy時に発動する条件
  }

  depends_on = [
    aws_iam_role.ecs_task_execution_role,
    aws_iam_role.ecs_task_role,
    aws_security_group.ecs,
    aws_ssm_parameter.image_url
  ]
}

data "aws_ecs_service" "oneshot" {
  cluster_arn  = aws_ecs_cluster.cluster.name
  service_name = "${var.service}-service"
  depends_on = [
    null_resource.ecspresso,
  ]
}

# ECSサービスのタスク数を自動的にスケーリング
resource "aws_appautoscaling_target" "nginx" {
  max_capacity       = 10
  min_capacity       = 1
  resource_id        = "service/${aws_ecs_cluster.cluster.name}/${data.aws_ecs_service.oneshot.service_name}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}