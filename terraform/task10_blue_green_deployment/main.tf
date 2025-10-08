provider "aws" {
  region = var.aws_region
}

# --- Look up the default VPC ---
data "aws_vpc" "default" {
  default = true
}

# --- Explicitly find only the PUBLIC subnets in the Default VPC ---
data "aws_subnets" "public" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
  filter {
    name   = "map-public-ip-on-launch"
    values = ["true"]
  }
}

# --- CloudWatch Log Group ---
resource "aws_cloudwatch_log_group" "strapi_app_logs" {
  name = "/ecs/strapi-bluegreen-app"

  tags = {
    Name = "${var.project_name}-log-group"
  }
}

# --- Security Groups ---
resource "aws_security_group" "alb" {
  name        = "${var.project_name}-alb-sg"
  description = "Allow HTTP/HTTPS traffic to ALB"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-alb-sg" }
}

resource "aws_security_group" "ecs_tasks" {
  name        = "${var.project_name}-ecs-tasks-sg"
  description = "Allow inbound traffic from ALB to ECS tasks"
  vpc_id      = data.aws_vpc.default.id
  ingress {
    description     = "Allow traffic from ALB on Strapi port"
    from_port       = 1337
    to_port         = 1337
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "${var.project_name}-ecs-tasks-sg" }
}

# --- Application Load Balancer (ALB) ---
resource "aws_lb" "main" {
  name               = "${var.project_name}-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb.id]
  subnets            = data.aws_subnets.public.ids
  tags = { Name = "${var.project_name}-alb" }
}

# Target Groups
resource "aws_lb_target_group" "blue" {
  name        = "${var.project_name}-blue-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/_health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200-299"
  }

  tags = { Name = "${var.project_name}-blue-tg" }
}

resource "aws_lb_target_group" "green" {
  name        = "${var.project_name}-green-tg"
  port        = 1337
  protocol    = "HTTP"
  vpc_id      = data.aws_vpc.default.id
  target_type = "ip"

  health_check {
    path                = "/_health"
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 10
    interval            = 30
    matcher             = "200-299"
  }

  tags = { Name = "${var.project_name}-green-tg" }
}

# Listener
resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.main.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.blue.arn
  }
}

# --- ECS Cluster and Task Definition ---
resource "aws_ecs_cluster" "main" {
  name = "${var.project_name}-cluster"
  tags = { Name = "${var.project_name}-cluster" }
}

# Find the new ECS Task Role created by the admin
data "aws_iam_role" "ecs_task_role" {
  name = "strapi-bluegreen-ecs-task-role"
}

resource "aws_ecs_task_definition" "strapi_app" {
  family                   = "${var.project_name}-strapi-app"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = "arn:aws:iam::145065858967:role/strapi-bluegreen-ecs-task-execution-role-sid"
  task_role_arn            = data.aws_iam_role.ecs_task_role.arn # Add the Task Role ARN
  container_definitions    = file("task-definition.json")

  # Ensure the log group exists before this is created
  depends_on = [aws_cloudwatch_log_group.strapi_app_logs]
}

# --- ECS Service ---
resource "aws_ecs_service" "strapi_app" {
  name            = "${var.project_name}-strapi-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.strapi_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  
  # Enable execute command for the service itself
  enable_execute_command = true

  network_configuration {
    subnets          = data.aws_subnets.public.ids
    security_groups  = [aws_security_group.ecs_tasks.id]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.blue.arn
    container_name   = "strapi-app-container"
    container_port   = 1337
  }

  deployment_controller {
    type = "CODE_DEPLOY"
  }

  depends_on = [aws_lb_listener.http]
}

# --- CodeDeploy ---
resource "aws_codedeploy_app" "strapi_app" {
  compute_platform = "ECS"
  name             = "${var.project_name}-strapi-app"
}

resource "aws_codedeploy_deployment_group" "strapi_app" {
  app_name               = aws_codedeploy_app.strapi_app.name
  deployment_group_name  = "${var.project_name}-deployment-group"
  deployment_config_name = "CodeDeployDefault.ECSCanary10Percent5Minutes"
  service_role_arn       = "arn:aws:iam::145065858967:role/strapi-bluegreen-codedeploy-role"

  ecs_service {
    cluster_name = aws_ecs_cluster.main.name
    service_name = aws_ecs_service.strapi_app.name
  }

  deployment_style {
    deployment_option = "WITH_TRAFFIC_CONTROL"
    deployment_type   = "BLUE_GREEN"
  }

  auto_rollback_configuration {
    enabled = true
    events  = ["DEPLOYMENT_FAILURE"]
  }

  blue_green_deployment_config {
    deployment_ready_option {
      action_on_timeout    = "CONTINUE_DEPLOYMENT"
    }
    terminate_blue_instances_on_deployment_success {
      action                           = "TERMINATE"
      termination_wait_time_in_minutes = 5
    }
  }

  load_balancer_info {
    target_group_pair_info {
      prod_traffic_route {
        listener_arns = [aws_lb_listener.http.arn]
      }
      target_group { name = aws_lb_target_group.blue.name }
      target_group { name = aws_lb_target_group.green.name }
    }
  }
}
