# Application Load Balancer

resource "aws_alb" "application_load_balancer" {
  name               = "ecs-load-balancer"
  load_balancer_type = "application"
  internal           = false
  subnets            = var.PUBLIC_SUBNETS_IDS
  security_groups    = [var.ALB_SECURITY_GROUP_ID]
  tags = {
    Name     = "ecs-load-balancer"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

# ALB Target Group

resource "aws_alb_target_group" "ecs_target_group" {
  name        = "ecs-target-group"
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.MAIN_VPC_ID
  tags = {
    Name     = "ecs-target-group"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

# ALB Listener

resource "aws_alb_listener" "application_load_balancer_listener" {
  load_balancer_arn = aws_alb.application_load_balancer.arn
  port              = 80
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_alb_target_group.ecs_target_group.arn
  }
}

# ECS Service AutoScaling

resource "aws_appautoscaling_target" "ecs_service_autoscaling_target" {
  max_capacity       = 3
  min_capacity       = 1
  resource_id        = "service/${var.ECS_CLUSTER_NAME}/${var.ECS_SERVICE_NAME}"
  scalable_dimension = "ecs:service:DesiredCount"
  service_namespace  = "ecs"
}

resource "aws_appautoscaling_policy" "ecs_service_autoscaling_policy" {
  name               = "ecs-service-autoscaling-policy"
  policy_type        = "TargetTrackingScaling"
  resource_id        = aws_appautoscaling_target.ecs_service_autoscaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.ecs_service_autoscaling_target.scalable_dimension
  service_namespace  = aws_appautoscaling_target.ecs_service_autoscaling_target.service_namespace
  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }
    target_value = "75"
  }
}
