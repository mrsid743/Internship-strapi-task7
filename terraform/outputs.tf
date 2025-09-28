output "alb_dns_name" {
  description = "The DNS name of the ALB"
  value       = aws_lb.strapi_alb.dns_name
}

output "ecs_cluster_name" {
  description = "The name of the ECS cluster"
  value       = aws_ecs_cluster.strapi_cluster.name
}

output "rds_endpoint" {
  description = "The endpoint of the RDS instance"
  value       = aws_db_instance.strapi_db.endpoint
}

