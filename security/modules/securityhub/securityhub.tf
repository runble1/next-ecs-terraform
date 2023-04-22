resource "aws_securityhub_account" "this" {}

resource "aws_securityhub_standards_subscription" "aws_standard" {
  standards_arn = "arn:aws:securityhub:ap-northeast-1::standards/aws-foundational-security-best-practices/v/1.0.0"
  depends_on    = [aws_securityhub_account.this]
}

resource "aws_securityhub_standards_subscription" "pci_dss" {
  standards_arn = "arn:aws:securityhub:ap-northeast-1::standards/pci-dss/v/3.2.1"
  depends_on    = [aws_securityhub_account.this]
}


resource "aws_securityhub_standards_control" "hardware_mfa" {
  standards_control_arn = "arn:aws:securityhub:ap-northeast-1:${data.aws_caller_identity.self.account_id}:control/pci-dss/v/3.2.1/PCI.IAM.4"

  control_status        = "DISABLED"
  disabled_reason       = "We handle MFA with Virtual MFA devices"

  depends_on = [aws_securityhub_standards_subscription.pci_dss]
}