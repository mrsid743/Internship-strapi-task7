resource "aws_ecs_cluster" "strapi_cluster" {
  name = "${var.project_name}-cluster"
}

resource "aws_ecs_service" "strapi_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.strapi_cluster.id
  task_definition = aws_ecs_task_definition.strapi_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    # Use all subnets from the Default VPC
    subnets         = data.aws_subnets.default.ids
    security_groups = [aws_security_group.ecs_service.id]
    # Assign a public IP to the task so it can pull the image from ECR
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.strapi_tg.arn
    container_name   = "${var.project_name}-container"
    container_port   = 1337
  }

  depends_on = [aws_lb_listener.strapi_listener]
}

resource "aws_ecs_task_definition" "strapi_app" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024"
  memory                   = "2048"

  execution_role_arn = data.aws_iam_role.ecs_task_execution_role.arn
  task_role_arn      = data.aws_iam_role.ecs_task_role.arn

  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = "${var.ecr_repo_url}:${var.image_tag}"
      essential = true
      portMappings = [
        {
          containerPort = 1337
          hostPort      = 1337
        }
      ]
      environment = [
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" },
        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = aws_db_instance.strapi_db.address },
        { name = "DATABASE_PORT", value = tostring(aws_db_instance.strapi_db.port) },
        { name = "DATABASE_NAME", value = aws_db_instance.strapi_db.db_name },
        { name = "DATABASE_USERNAME", value = aws_db_instance.strapi_db.username },
        { name = "DATABASE_PASSWORD", value = var.db_password },
        { name = "DATABASE_SSL", value = "false" },
        { name = "JWT_SECRET", value = var.jwt_secret },
        { name = "ADMIN_JWT_SECRET", value = var.admin_jwt_secret },
        { name = "API_TOKEN_SALT", value = var.api_token_salt },
        { name = "APP_KEYS", value = var.app_keys }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          # This now correctly points to the log group defined in cloudwatch.tf
          "awslogs-group"         = aws_cloudwatch_log_group.main.name
          "awslogs-region"        = var.aws_region
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])
}