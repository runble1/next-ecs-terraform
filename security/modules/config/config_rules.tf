locals {
  rule_identifier = "restricted-ssh"
}

# ====================
# Config Rules
# ====================
resource "aws_config_config_rule" "restricted_ssh" {
  name        = local.rule_identifier
  description = "Checks whether security groups that are in use disallow unrestricted incoming SSH traffic."

  source {
    owner             = "AWS"
    source_identifier = "INCOMING_SSH_DISABLED"
  }

  depends_on = [aws_config_configuration_recorder.recorder]
}