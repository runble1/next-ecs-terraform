variable "function_name" {}
variable "log_group_name" {}

variable "metric_name" {}
variable "metric_name_space" {}

# ====================
# Logs Metric Filter
# ====================
resource "aws_cloudwatch_log_metric_filter" "lambdas_errors" {
  name           = "${var.function_name}-error-filter"
  pattern        = "ERROR" #ターゲット文字列
  log_group_name = var.log_group_name

  metric_transformation {
    name      = var.metric_name
    namespace = var.metric_name_space
    value     = "1"
    unit      = "Count"
  }
}

# ====================
# Metric Alarm
# ====================
resource "aws_cloudwatch_metric_alarm" "lambdas_errors" {
  alarm_name        = "${var.function_name}-error-alarm"
  alarm_description = "${var.function_name} with errors"

  # 60秒間に1回でもエラーログが発生した場合
  period              = "60"    # 評価期間（秒）
  threshold           = "1"     # しきい値
  unit                = "Count" # 1カウント
  evaluation_periods  = "1"     # しきい値が超えた回数、1回以上
  statistic           = "Sum"   #合計
  comparison_operator = "GreaterThanOrEqualToThreshold"

  namespace   = var.metric_name_space
  metric_name = var.metric_name

  # データ不足時のアクションなし
  insufficient_data_actions = []

  alarm_actions = [aws_sns_topic.lambdas_errors.arn]
}

# ====================
# SNS
# ====================
resource "aws_sns_topic" "lambdas_errors" {
  name = "${var.function_name}-error-topic"
}

