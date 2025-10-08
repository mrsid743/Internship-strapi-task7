output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer."
  value       = aws_lb.main.dns_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster."
  value       = aws_ecs_cluster.main.name
}

output "blue_target_group_arn" {
  description = "The ARN of the Blue target group."
  value       = aws_lb_target_group.blue.arn
}

output "green_target_group_arn" {
  description = "The ARN of the Green target group."
  value       = aws_lb_target_group.green.arn
}

