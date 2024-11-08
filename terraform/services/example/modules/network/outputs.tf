output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "public_subnet_1a_id" {
  value = aws_subnet.public_subnet_1a.id
}

output "public_subnet_1c_id" {
  value = aws_subnet.public_subnet_1c.id
}

output "private_subnet_1a_id" {
  value = aws_subnet.private_subnet_1a.id
}

output "alb_security_group_id" {
  value = aws_security_group.alb_security_group.id
}

output "ecs_security_group_id" {
  value = aws_security_group.ecs_security_group.id
}
