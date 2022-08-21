output "aurora_db_host" {
  value = aws_rds_cluster.aurora_cluster.endpoint
}

output "aurora_db_port_number" {
  value = aws_rds_cluster.aurora_cluster.port
}

output "aurora_db_name" {
  value = aws_rds_cluster.aurora_cluster.database_name
}

output "aurora_db_user" {
  value = aws_rds_cluster.aurora_cluster.master_username
}
