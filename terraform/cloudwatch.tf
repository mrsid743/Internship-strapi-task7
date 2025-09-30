# Create a CloudWatch Log Group for the ECS tasks
resource "aws_cloudwatch_log_group" "main" {
  name = "/ecs/${var.project_name}"

  tags = {
    Name = "${var.project_name}-log-group"
  }
}

# Create a CloudWatch Dashboard for monitoring key metrics
resource "aws_cloudwatch_dashboard" "main" {
  dashboard_name = "${var.project_name}-dashboard"
  dashboard_body = jsonencode({
    widgets = [
      {
        type   = "metric"
        x      = 0
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "CPUUtilization", "ClusterName", aws_ecs_cluster.strapi_cluster.name, "ServiceName", aws_ecs_service.strapi_service.name],
            [".", "MemoryUtilization", ".", ".", ".", "."]
          ]
          period = 300
          stat   = "Average"
          region = var.aws_region
          title  = "ECS Service CPU & Memory Utilization"
        }
      },
      {
        type   = "metric"
        x      = 12
        y      = 0
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ApplicationELB", "HealthyHostCount", "LoadBalancer", element(split("/", aws_lb.strapi_alb.arn), 1), "TargetGroup", element(split("/", aws_lb_target_group.strapi_tg.arn), 1)],
            [".", "UnHealthyHostCount", ".", ".", ".", "."]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "ALB Target Health"
        }
      },
      {
        type   = "metric"
        x      = 0
        y      = 7
        width  = 12
        height = 6
        properties = {
          metrics = [
            ["AWS/ECS", "RunningTaskCount", "ClusterName", aws_ecs_cluster.strapi_cluster.name, "ServiceName", aws_ecs_service.strapi_service.name]
          ]
          period = 60
          stat   = "Average"
          region = var.aws_region
          title  = "Running Task Count"
        }
      }
    ]
  })
}

# Create a CloudWatch Alarm for high CPU utilization
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.project_name}-high-cpu-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80" # Alarm if CPU is >= 80% for 4 minutes
  alarm_description   = "This alarm triggers when the ECS service CPU utilization is high."

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }

  # Note: To receive notifications, you would add an 'alarm_actions' pointing to an SNS topic ARN.
}

# Create a CloudWatch Alarm for high Memory utilization
resource "aws_cloudwatch_metric_alarm" "high_memory" {
  alarm_name          = "${var.project_name}-high-memory-utilization"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = "120"
  statistic           = "Average"
  threshold           = "80" # Alarm if Memory is >= 80% for 4 minutes
  alarm_description   = "This alarm triggers when the ECS service memory utilization is high."

  dimensions = {
    ClusterName = aws_ecs_cluster.strapi_cluster.name
    ServiceName = aws_ecs_service.strapi_service.name
  }

  # Note: To receive notifications, you would add an 'alarm_actions' pointing to an SNS topic ARN.
}

