output "alb_security_group_id" {
  value = aws_security_group.alb_security_group.id
}

output "ecs_service_security_group_id" {
  value = aws_security_group.ecs_service_security_group.id
}

output "ecs_task_definition_execution_role_arn" {
  value = aws_iam_role.ecs_task_definition_execution_role.arn
}

output "secrets_manager_aurora_password" {
  value = random_password.master_password.result
}

output "aurora_security_group_id" {
  value = aws_security_group.aurora_security_group.id
}

output "efs_mount_targets_security_group_id" {
  value = aws_security_group.efs_mount_targets_security_group.id
}
