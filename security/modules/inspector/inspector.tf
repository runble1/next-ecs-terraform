# ====================
# Inspector
# ====================
/*
data "aws_caller_identity" "self" {}

resource "aws_inspector2_enabler" "example" {
  account_ids    = [data.aws_caller_identity.self.account_id]
  resource_types = ["ECR"]
}
*/
