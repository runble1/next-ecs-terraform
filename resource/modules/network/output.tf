output "vpc_id" {
  value = aws_vpc.main.id
}

output "nat_gw_ip" {
  description = "JIRA アクセスのための IP 許可申請に必要"
  value       = aws_eip.nat_gateway_0.public_ip
}

output "subnet_public_1a_id" {
  value = aws_subnet.public_1a.id
}

output "subnet_public_1c_id" {
  value = aws_subnet.public_1c.id
}

output "sg_id" {
  value = aws_security_group.slackbot_sg.id
}
