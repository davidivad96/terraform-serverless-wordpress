output "ecs_target_group_arn" {
  value = aws_alb_target_group.ecs_target_group.arn
}

output "alb_arn" {
  value = aws_alb.application_load_balancer.arn
}
