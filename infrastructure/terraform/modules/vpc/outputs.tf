output "vpc_id" {
  description = "ID of the Week 13 VPC"
  value       = aws_vpc.this.id
}

output "vpc_cidr_block" {
  description = "CIDR block assigned to the VPC"
  value       = aws_vpc.this.cidr_block
}

output "availability_zones" {
  description = "Availability Zones used by the VPC"
  value       = var.availability_zones
}

output "public_subnet_ids" {
  description = "Ordered list of public subnet IDs"
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.public[availability_zone].id
  ]
}

output "private_db_subnet_ids" {
  description = "Ordered list of private database subnet IDs"
  value = [
    for availability_zone in var.availability_zones :
    aws_subnet.private_db[availability_zone].id
  ]
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.this.id
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.public.id
}

output "private_db_route_table_id" {
  description = "ID of the private database route table"
  value       = aws_route_table.private_db.id
}
