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
  family                   = "ecs-task-definition"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = var.ECS_TASK_DEFINITION_EXECUTION_ROLE_ARN
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
        value : var.AURORA_CLUSTER.endpoint,
        }, {
        name : "WORDPRESS_DATABASE_PORT_NUMBER",
        value : tostring(var.AURORA_CLUSTER.port),
        }, {
        name : "WORDPRESS_DATABASE_NAME",
        value : var.AURORA_CLUSTER.database_name,
        }, {
        name : "WORDPRESS_DATABASE_USER",
        value : var.AURORA_CLUSTER.master_username,
        }, {
        name : "WORDPRESS_DATABASE_PASSWORD",
        value : var.AURORA_CLUSTER_PASSWORD,
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
  volume {
    name = "bitnami-wordpress-volume"
    efs_volume_configuration {
      file_system_id     = var.EFS_FILE_SYSTEM.id
      root_directory     = "/"
      transit_encryption = "ENABLED"
    }
  }
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
  depends_on = [var.AURORA_CLUSTER, var.EFS_FILE_SYSTEM]
  tags = {
    Name     = "ecs-service"
    APP_NAME = "${var.APP_NAME}"
    ENV      = "${var.ENV}"
  }
}
