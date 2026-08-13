output "vpc_id" {
  description = "ID of the Bedrock VPC"
  value       = aws_vpc.bedrock.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC, used when writing security group rules"
  value       = aws_vpc.bedrock.cidr_block
}

output "public_subnet_ids" {
  description = "IDs of the public subnets, where the ALB is placed"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets, where worker nodes and RDS run"
  value       = aws_subnet.private[*].id
}

output "nat_public_ip" {
  description = "Public IP of the NAT Gateway, the address all outbound traffic from private subnets appears to come from"
  value       = aws_eip.nat.public_ip
}
