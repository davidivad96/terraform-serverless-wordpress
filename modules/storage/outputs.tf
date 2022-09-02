output "efs_file_system" {
  value = aws_efs_file_system.efs_file_system
}

output "efs_file_system_access_point" {
  value = aws_efs_access_point.efs_file_system_access_point
}
