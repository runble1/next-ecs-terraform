# 
# Flow Logs
#
resource "aws_flow_log" "vpc_flow_log" {
  log_destination      = aws_s3_bucket.flow_log_bucket.arn
  log_destination_type = "s3"
  traffic_type         = "ALL"
  vpc_id               = aws_vpc.main.id
}

#
# S3
# 
resource "aws_s3_bucket" "flow_log_bucket" {
  bucket        = "${var.env}-${var.service}-flow-log-bucket"
  force_destroy = true
}
