resource "aws_cloudwatch_log_group" "log_group" {
  name              = "/aws/events/ECSStoppedTasksEvent"
  retention_in_days = 30
}

resource "aws_cloudwatch_event_rule" "event_rule" {
  name        = "ECSStoppedTasksEvent"
  description = "Triggered when an Amazon ECS Task is stopped"

  event_pattern = <<PATTERN
{
  "source": [
    "aws.ecs"
  ],
  "detail-type": [
    "ECS Task State Change"
  ],
  "detail": {
    "desiredStatus": [
      "STOPPED"
    ],
    "lastStatus": [
      "STOPPED"
    ]
  }
}
PATTERN
}

resource "aws_cloudwatch_event_target" "event_target" {
  rule      = aws_cloudwatch_event_rule.event_rule.name
  target_id = "ECSStoppedTasks"
  arn       = aws_cloudwatch_log_group.log_group.arn
}

resource "aws_iam_policy" "log_events_policy" {
  name        = "LogEventsPolicy"
  description = "Policy to allow CloudWatch Events to put logs"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "LogEventsPolicy",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "${aws_cloudwatch_log_group.log_group.arn}"
    }
  ]
}
EOF
}
