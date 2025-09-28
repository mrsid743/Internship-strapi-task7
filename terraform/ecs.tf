# ecs.tf

# Create the ECS Cluster
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"

  tags = {
    Name = "${var.project_name}-cluster"
  }
}

# Create the CloudWatch log group for the Strapi container
resource "aws_cloudwatch_log_group" "strapi_logs" {
  name              = "/ecs/${var.project_name}"
  retention_in_days = 7

  tags = {
    Name = "${var.project_name}-log-group"
  }
}

# Create the ECS Task Definition
resource "aws_ecs_task_definition" "strapi_app" {
  family                   = "${var.project_name}-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "1024" # 1 vCPU
  memory                   = "2048" # 2 GB RAM
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn

  # Define the container for the Strapi application
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container",
      image     = "${data.aws_ecr_repository.strapi_repo.repository_url}:${var.image_tag}",
      cpu       = 1024,
      memory    = 2048,
      essential = true,
      portMappings = [
        {
          containerPort = 1337,
          hostPort      = 1337
        }
      ],
      # Strapi environment variables
      environment = [
        { name = "HOST", value = "0.0.0.0" },
        { name = "PORT", value = "1337" },
        { name = "DATABASE_CLIENT", value = "postgres" },
        { name = "DATABASE_HOST", value = aws_db_instance.main.address },
        { name = "DATABASE_PORT", value = tostring(aws_db_instance.main.port) },
        { name = "DATABASE_NAME", value = aws_db_instance.main.db_name },
        { name = "DATABASE_USERNAME", value = aws_db_instance.main.username },
        { name = "DATABASE_SSL", value = "false" }, # Adjust if you enable SSL on RDS
        # Generate these values and store them securely, e.g., in AWS Secrets Manager
        { name = "APP_KEYS", value = "2lRiLB0pHcTZYRleHW67twK6/CIlWwjpFRlk05zN8Mo=,/cu4QH8+eaZDI0RLJ7KeMcUZPur/hNPY9pO54zPjL+o=" },
        { name = "API_TOKEN_SALT", value = "0uPl/PaAV6xpIZlNovRGtfpJK7okRIVk2JZJX30kt9M" },
        { name = "ADMIN_JWT_SECRET", value = "bcmZ/02AxoyuV0/Hz0z95IyPLrr/KiOLx90viPsnHrg=" },
        { name = "JWT_SECRET", value = "xU6cbE72A9hAqFsTHt6FMcXECBzMIo27lO1zDEdYKVE=" }
      ],
      secrets = [
        {
          name      = "DATABASE_PASSWORD",
          valueFrom = aws_db_instance.main.password
        }
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          "awslogs-group"         = aws_cloudwatch_log_group.strapi_logs.name,
          "awslogs-region"        = var.aws_region,
          "awslogs-stream-prefix" = "ecs"
        }
      }
    }
  ])

  tags = {
    Name = "${var.project_name}-task-def"
  }
}

# Create the ECS Service
resource "aws_ecs_service" "strapi_service" {
  name            = "${var.project_name}-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.strapi_app.arn
  desired_count   = 1 # Start with one instance of the application
  launch_type     = "FARGATE"

  # Configure the service to use the public subnets and security group
  network_configuration {
    subnets         = aws_subnet.public.*.id
    security_groups = [aws_security_group.ecs_service.id]
    assign_public_ip = true
  }

  # Connect the service to the Application Load Balancer
  load_balancer {
    target_group_arn = aws_lb_target_group.strapi.arn
    container_name   = "${var.project_name}-container"
    container_port   = 1337
  }

  # Ensure the service waits for the ALB to be ready before starting
  depends_on = [aws_lb_listener.http]
}
