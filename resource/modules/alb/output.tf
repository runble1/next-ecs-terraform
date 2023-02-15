output "public_dns" {
  value = aws_lb.for_webserver.dns_name
}

output "target_group_arn" {
  value = aws_lb_target_group.for_webserver.arn
}
