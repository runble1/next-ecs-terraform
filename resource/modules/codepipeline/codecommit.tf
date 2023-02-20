resource "aws_codecommit_repository" "this" {
  repository_name = var.repository_name
}

output "codecommit_url" {
  value = aws_codecommit_repository.this.clone_url_http
}