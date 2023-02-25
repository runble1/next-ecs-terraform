resource "aws_codepipeline" "this" {
  name     = "${var.prefix}-${var.env}-pipeline"
  role_arn = aws_iam_role.codepipeline.arn

  artifact_store {
    location = aws_s3_bucket.artifacts_store.id
    type     = "S3"
  }

  stage {
    name = "Secrets_Check"
    action {
      category = "Build"
      configuration = {
        ProjectName = aws_codebuild_project.secrets_check.name
      }
      input_artifacts = ["source_output"]
      name            = aws_codebuild_project.secrets_check.name
      provider        = "CodeBuild"
      owner           = "AWS"
      version         = "1"
      role_arn        = aws_iam_role.codepipeline_codebuild.arn
    }
  }
}