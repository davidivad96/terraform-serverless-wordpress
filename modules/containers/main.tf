// ECS Cluster

resource "aws_ecs_cluster" "ecs_cluster" {
  name = "ecs-cluster"
  tags = {
    Name     = "ecs-cluster"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

// ECS Task Definition

resource "aws_ecs_task_definition" "ecs_task_definition" {
  family = "ecs-task-definition"
  container_definitions = jsonencode([
    {
      name : "bitnami-wordpress",
      image : "bitnami/wordpress:6.0.1",
      cpu : 256,
      memory : 512,
      portMappings : [{
        containerPort : 8080,
        hostPort : 8080
      }],
      environment : [{
        name : "WORDPRESS_DATABASE_HOST",
        value : var.AURORA_DB_HOST,
        }, {
        name : "WORDPRESS_DATABASE_PORT_NUMBER",
        value : tostring(var.AURORA_DB_PORT_NUMBER),
        }, {
        name : "WORDPRESS_DATABASE_NAME",
        value : var.AURORA_DB_NAME,
        }, {
        name : "WORDPRESS_DATABASE_USER",
        value : var.AURORA_DB_USER,
        }, {
        name : "WORDPRESS_DATABASE_PASSWORD",
        value : var.AURORA_DB_PASSWORD,
      }],
      logConfiguration : {
        logDriver : "awslogs",
        options : {
          awslogs-create-group : "true",
          awslogs-group : "ecs-task-definition-awslogs",
          awslogs-stream-prefix : "ecs-task-definition",
          awslogs-region : var.AWS_REGION,
        },
      }
    }
  ])
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ECS_TASK_DEFINITION_EXECUTION_ROLE_ARN
  tags = {
    Name     = "ecs-task-definition"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}

// ECS Service

resource "aws_ecs_service" "ecs_service" {
  name            = "ecs-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.ecs_task_definition.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  load_balancer {
    target_group_arn = var.TARGET_GROUP_ARN
    container_name   = "bitnami-wordpress"
    container_port   = 8080
  }
  network_configuration {
    subnets         = var.PRIVATE_SUBNETS_IDS
    security_groups = [var.ECS_SERVICE_SECURITY_GROUP_ID]
  }
  tags = {
    Name     = "ecs-service"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}
