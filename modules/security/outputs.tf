output "alb_security_group_id" {
  value = aws_security_group.alb_security_group.id
}

output "ecs_service_security_group_id" {
  value = aws_security_group.ecs_service_security_group.id
}

output "ecs_task_definition_execution_role_arn" {
  value = aws_iam_role.ecs_task_definition_execution_role.arn
}

output "secrets_manager_db_password" {
  value = random_password.master_password.result
}

output "db_security_group_id" {
  value = aws_security_group.aurora_db_security_group.id
}
