output "repository_url" {
  value = module.ecr.repository_url
}

output "public_dns" {
  value = module.alb.public_dns
}
