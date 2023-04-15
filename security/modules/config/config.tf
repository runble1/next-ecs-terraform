# ====================
# Config
# ====================
resource "aws_config_configuration_recorder" "recorder" {
  name     = "${var.name}-config-recorder"
  role_arn = aws_iam_role.config_role.arn


  recording_group {
    /*
    all_supported = true
    include_global_resource_types = true
    */
    all_supported = false
    resource_types = [
      "AWS::EC2::Instance",
      "AWS::EC2::SecurityGroup"
    ]
  }
}

resource "aws_config_configuration_recorder_status" "recorder" {
  name       = aws_config_configuration_recorder.recorder.name
  is_enabled = true
  depends_on = [aws_config_delivery_channel.delivery_channel]
}

resource "aws_config_delivery_channel" "delivery_channel" {
  name           = "${var.name}-config-delivery-channel"
  s3_bucket_name = aws_s3_bucket.config_bucket.bucket
  #s3_key_prefix  = "${data.aws_caller_identity.self.account_id}" #OUIDとか
  depends_on = [aws_config_configuration_recorder.recorder]
}

# ====================
# IAM
# ====================
resource "aws_iam_role" "config_role" {
  name = "${var.name}-config-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
      }
    ]
  })

  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AWS_ConfigRole"]
}

resource "aws_iam_role_policy" "config_role_policy" {
  name = "${var.name}-config-delivery-policy"
  role = aws_iam_role.config_role.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:*"
        ]
        Effect = "Allow"
        Resource = [
          aws_s3_bucket.config_bucket.arn,
          "${aws_s3_bucket.config_bucket.arn}/*"
        ]
      }
    ]
  })
}

# ====================
# S3 for Config
# ====================
resource "aws_s3_bucket" "config_bucket" {
  bucket = "${var.name}-config-bucket-${data.aws_caller_identity.self.account_id}"
}

resource "aws_s3_bucket_policy" "config_bucket_policy" {
  bucket = aws_s3_bucket.config_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "AWSConfigBucketPermissionsCheck"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action = [
          "s3:GetBucketAcl",
          "s3:ListBucket",
        ]
        Resource = aws_s3_bucket.config_bucket.arn
      },
      {
        Sid    = "AWSConfigBucketDelivery"
        Effect = "Allow"
        Principal = {
          Service = "config.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.config_bucket.arn}/AWSLogs/${data.aws_caller_identity.self.account_id}/Config/*"
        Condition = {
          StringEquals = {
            "s3:x-amz-acl" = "bucket-owner-full-control"
          }
        }
      }
    ]
  })
}
