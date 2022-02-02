output "subnets" {
  value = aws_subnet.private[*].id
}
output "alb_hostname" {
  value = aws_alb.application_load_balancer.dns_name
}

output "vpc_id" {
  value = aws_vpc.main.id
}