output "main_vpc_id" {
  value = aws_vpc.main_vpc.id
}

output "public_subnets_ids" {
  value = [
    for subnet in aws_subnet.public_subnets : subnet.id
  ]
}

output "private_subnets_ids" {
  value = [
    for subnet in aws_subnet.private_subnets : subnet.id
  ]
}
