output "vpc_id" {
  value = aws_vpc.test-vpc.id
}

output "lb_dns_name" {
  value = aws_lb.test-lb.dns_name
}

