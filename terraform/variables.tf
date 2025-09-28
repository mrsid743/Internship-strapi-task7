variable "aws_region" {
  description = "The AWS region to deploy resources in."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "The name of the project, used for naming resources."
  type        = string
  default     = "strapi-ecs-app"
}

variable "ecr_repo_url" {
  description = "The URL of the ECR repository."
  type        = string
}

variable "image_tag" {
  description = "The tag of the Docker image to deploy."
  type        = string
  default     = "latest"
}

# IAM Role Names for existing roles
variable "ecs_task_execution_role_name" {
  description = "The name of the existing IAM role for ECS task execution."
  type        = string
  default     = "ec2_ecr_full_access_role"
}

variable "ecs_task_role_name" {
  description = "The name of the existing IAM role for the ECS task itself."
  type        = string
  default     = "internship-strapi-task-role"
}

# Secrets
variable "db_password" {
  description = "The password for the RDS database master user."
  type        = string
  sensitive   = true
}

variable "jwt_secret" {
  description = "The JWT secret for Strapi."
  type        = string
  sensitive   = true
}

variable "admin_jwt_secret" {
  description = "The Admin JWT secret for Strapi."
  type        = string
  sensitive   = true
}

variable "api_token_salt" {
  description = "The API token salt for Strapi."
  type        = string
  sensitive   = true
}

variable "app_keys" {
  description = "The app keys for Strapi."
  type        = string
  sensitive   = true
}

