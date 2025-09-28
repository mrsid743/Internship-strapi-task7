# variables.tf

variable "aws_region" {
  description = "The AWS region where resources will be created."
  type        = string
  default     = "ap-south-1"
}

variable "project_name" {
  description = "The name of the project, used for tagging resources."
  type        = string
  default     = "strapi-ecs-app"
}

variable "ecr_repository_name" {
  description = "The name of the pre-existing ECR repository."
  type        = string
  default     = "siddhant-strapi"
}

variable "image_tag" {
  description = "The tag of the Docker image to deploy. This is passed from the CI/CD pipeline."
  type        = string
  default     = "latest" # Default value, will be overridden by GitHub Actions
}

variable "db_username" {
  description = "The master username for the RDS database."
  type        = string
  default     = "strapiadmin"
}

variable "db_password" {
  description = "The master password for the RDS database."
  type        = string
  sensitive   = true
  # Note: A randomly generated password is used by default in rds.tf.
  # Set this variable only if you need a specific password.
}

variable "ec2_key_name" {
  description = "The name of the EC2 key pair to allow SSH access."
  type        = string
  default     = "strapi-mumbai-key"
}

