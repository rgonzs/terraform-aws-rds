output "vpc_id" {
  value = aws_vpc.devops_vpc.id
}

output "subnets_app_ids" {
  value = [aws_subnet.subnet_app_a.id, aws_subnet.subnet_app_b.id, aws_subnet.subnet_app_c.id]
}

output "subnets_db_ids" {
  value = [aws_subnet.subnet_db_a.id,aws_subnet.subnet_db_b.id,aws_subnet.subnet_db_c.id]
}
