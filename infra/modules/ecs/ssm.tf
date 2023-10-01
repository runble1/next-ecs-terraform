data "aws_ssm_parameter" "image_name" {
  name = "/${var.service}/image_name"
}
