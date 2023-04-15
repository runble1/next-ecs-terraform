output "nat_gw_ip" {
  description = "JIRA アクセスのための IP 許可申請に必要"
  value       = aws_eip.nat_gateway_0.public_ip
}

output "subnet_private_id" {
  value = aws_subnet.private_0.id
}

output "sg_id" {
  value = aws_security_group.slackbot_sg.id
}